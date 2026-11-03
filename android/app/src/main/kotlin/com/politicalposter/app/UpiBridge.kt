package com.politicalposter.app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.view.ViewGroup
import android.webkit.WebView
import android.widget.FrameLayout
import com.razorpay.ApplicationDetails
import com.razorpay.BaseRazorpay
import com.razorpay.PaymentData
import com.razorpay.PaymentResultWithDataListener
import com.razorpay.Razorpay
import com.razorpay.RzpUpiSupportedAppsCallback
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.lang.ref.WeakReference
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Direct-UPI native bridge (Alnico Direct UPI Standard).
 *
 *  - detect (`listUpiApps`) — which UPI apps on this device can sign an AutoPay mandate.
 *  - launch (`submitDirect`) — hand the mandate straight to the chosen app.
 *
 * Load-bearing properties. Each is a requirement, not a preference:
 *
 *  - Detection asks the AutoPay-specific API but keeps the plain list as a FLOOR. AutoPay
 *    may only NARROW the plain list, never replace it with nothing.
 *  - An empty list is a CORRECT answer, not an error (D6/C15).
 *  - The Razorpay instance and WebView are CACHED across attempts, guarded by [ownerRef]
 *    so a recreated Activity forces a rebuild (D13). Caching without that guard is what
 *    produced the 2026-07-27 retry bug. Never remove the guard to simplify the caching.
 *  - Per-attempt listeners, released exactly once. Never removeAllListeners (D16).
 */
object UpiBridge {

    const val CHANNEL = "com.alnico.sanatanapp/upi"

    private val main = Handler(Looper.getMainLooper())

    /** Cached across attempts; rebuilt only when [ownerRef] goes stale (D13). */
    private var razorpay: Razorpay? = null

    /** The off-screen WebView the SDK runs its handshake in. Cached; see [ensureReady]. */
    private var handshakeView: WebView? = null

    /** Monotonic attempt id. A result carrying a stale id is ignored (D16). */
    private var attemptId: Long = 0

    /**
     * The Activity that owns [razorpay] and [handshakeView].
     *
     * Paying by UPI backgrounds the app, and Android may destroy and recreate the Activity
     * while the user is away. A cached WebView still parented to the destroyed Activity
     * cannot complete the handshake, and the SDK's error looks exactly like a user
     * cancellation — so the user is told "Payment cancelled" when they never cancelled.
     *
     * Reproduce deterministically: Developer options -> Don't keep activities ON.
     */
    private var ownerRef: WeakReference<Activity>? = null

    fun handle(activity: Activity, call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> init(activity, call, result)
            "listUpiApps" -> listUpiApps(activity, call, result)
            "submitDirect" -> submitDirect(activity, call, result)
            else -> result.notImplemented()
        }
    }

    /** Build the SDK + WebView while the paywall is idle, off the tap path. */
    private fun init(activity: Activity, call: MethodCall, result: MethodChannel.Result) {
        val keyId = call.argument<String>("keyId")
        if (keyId.isNullOrEmpty()) {
            result.error("UPI_BAD_ARGS", "keyId is required", null)
            return
        }
        try {
            ensureReady(activity, keyId)
            result.success(true)
        } catch (e: Throwable) {
            // Pre-building is an optimisation, never a precondition.
            result.success(false)
        }
    }

    /**
     * Guarantees a usable Razorpay + WebView pair owned by [activity], rebuilding when the
     * cached pair is stale (D13): a different Activity, one that is finishing or destroyed,
     * or a detached WebView.
     */
    private fun ensureReady(activity: Activity, keyId: String) {
        val owner = ownerRef?.get()
        val stale = razorpay == null ||
            handshakeView == null ||
            owner !== activity ||
            activity.isFinishing ||
            activity.isDestroyed ||
            handshakeView?.parent == null

        if (!stale) return

        teardown()
        val rzp = Razorpay(activity, keyId)
        razorpay = rzp
        attachHandshakeView(activity, rzp)
        ownerRef = WeakReference(activity)
    }

    // ------------------------------------------------------------------ detection

    /**
     * Two SDK APIs exist:
     *  - getAppsWhichSupportUpi(Context) — SYNCHRONOUS, returns a List. What the RN
     *    reference ships in production, completing real mandates.
     *  - getAppsWhichSupportAutoPayIntent(Context, cb) — async, AutoPay-specific, and
     *    therefore semantically the right question for a recurring:'1' flow.
     *
     * The AutoPay call is better in theory and unproven in practice: no failure channel,
     * no guarantee it fires. So the synchronous list is the FLOOR and AutoPay only narrows
     * it. An empty AutoPay list is far more likely to mean "this API needs something we
     * did not give it" than "none of your wallets can sign a mandate".
     *
     * Both counts are returned so an empty row is diagnosable from a log rather than
     * guessed at from a screenshot.
     */
    private fun listUpiApps(context: Context, call: MethodCall, result: MethodChannel.Result) {
        val priority = call.argument<List<String>>("priority") ?: emptyList()
        val maxApps = call.argument<Int>("maxApps") ?: 0
        val preferAutoPay = call.argument<Boolean>("preferAutoPay") ?: true
        val autoPayWaitMs = (call.argument<Int>("autoPayWaitMs") ?: 500).toLong()
        // Absolute ceiling measured from handler entry. The Dart side passes its own invoke
        // budget minus a margin, so we always answer just INSIDE its timeout rather than
        // letting it fire and the feature vanish.
        val hardDeadlineMs = (call.argument<Int>("hardDeadlineMs") ?: 2500).toLong()

        val enteredAt = android.os.SystemClock.uptimeMillis()
        fun elapsed() = android.os.SystemClock.uptimeMillis() - enteredAt

        // Populated by the background enumeration below. Read by whichever timer fires
        // first, which may be before enumeration has finished — hence the atomic.
        val plainRef = java.util.concurrent.atomic.AtomicReference<List<ApplicationDetails>>(
            emptyList(),
        )
        val answered = AtomicBoolean(false)

        fun answer(apps: List<ApplicationDetails>, source: String, autoPayCount: Int) {
            if (!answered.compareAndSet(false, true)) return
            val plainCount = plainRef.get().size
            android.util.Log.i(
                "UpiBridge",
                "=== UPI: answering source=$source apps=${apps.size} at ${elapsed()}ms ===",
            )
            main.post {
                result.success(
                    mapOf(
                        "apps" to rank(apps, priority, maxApps),
                        "source" to source,
                        "plainCount" to plainCount,
                        "autoPayCount" to autoPayCount,
                    ),
                )
            }
        }

        // Posted FIRST, before any enumeration work is started. Scheduling it afterwards —
        // as the reference implementation does — means a slow enumeration delays the very
        // timer meant to protect against a slow enumeration, and the Dart timeout wins.
        main.postDelayed({
            answer(plainRef.get(), "hard_deadline_fell_back_to_plain", -1)
        }, hardDeadlineMs)

        // getAppsWhichSupportUpi is SYNCHRONOUS and, on a cold SDK, does real work before it
        // returns (it resolves the gateway's app/logo config). Running it on the platform
        // main thread blocks the very Handler the fallback timers are posted to, so a slow
        // device answers NOTHING at all rather than answering late. Off-thread it is.
        Thread({
            val plain = runCatching {
                BaseRazorpay.getAppsWhichSupportUpi(context) ?: emptyList()
            }.getOrElse { emptyList() }
            plainRef.set(plain)
            android.util.Log.i(
                "UpiBridge",
                "=== UPI: plain enumeration took ${elapsed()}ms -> ${plain.size} app(s) ===",
            )

            if (answered.get()) return@Thread

            if (!preferAutoPay) {
                answer(plain, "plain", -1)
                return@Thread
            }

            // The AutoPay API hands back through a callback; keep the call itself on main.
            main.post {
                if (answered.get()) return@post
                try {
                    BaseRazorpay.getAppsWhichSupportAutoPayIntent(
                        context,
                        RzpUpiSupportedAppsCallback { apps ->
                            val auto = apps ?: emptyList()
                            if (auto.isEmpty()) {
                                answer(plain, "autopay_empty_fell_back_to_plain", 0)
                            } else {
                                answer(auto, "autopay", auto.size)
                            }
                        },
                    )
                } catch (e: Throwable) {
                    answer(plain, "autopay_threw_fell_back_to_plain:" + (e.message ?: "?"), -1)
                    return@post
                }

                // The callback may never fire. Settle for the synchronous list rather than
                // waiting out the hard deadline with a list already in hand.
                main.postDelayed({
                    answer(plain, "autopay_timed_out_fell_back_to_plain", -1)
                }, autoPayWaitMs)
            }
        }, "upi-detect").start()
    }

    /** Caller-supplied order. Unlisted apps keep their order but sort last. */
    private fun rank(
        apps: List<ApplicationDetails>,
        priority: List<String>,
        maxApps: Int,
    ): List<Map<String, Any?>> {
        // Match on package id AND display name: OEM and regional builds ship different
        // package ids for the same wallet.
        fun rankOf(app: ApplicationDetails): Int {
            val pkg = (app.packageName ?: "").lowercase()
            val name = (app.appName ?: "").lowercase()
            priority.forEachIndexed { idx, wanted ->
                val w = wanted.lowercase()
                if (pkg == w || pkg.contains(w) || (w.isNotEmpty() && name.contains(w))) {
                    return idx
                }
                // Google Pay's package shares no substring with its display name.
                if (w.contains("paisa") &&
                    (name.contains("gpay") || name.contains("google pay"))
                ) {
                    return idx
                }
            }
            return priority.size
        }

        val ranked = apps.distinctBy { it.packageName }.sortedBy { rankOf(it) }
        val limited = if (maxApps > 0) ranked.take(maxApps) else ranked

        return limited.map { app ->
            mapOf(
                "packageName" to app.packageName,
                "appName" to (app.appName ?: app.packageName),
                // The CDN brand logo. PREFER THIS over iconBase64 in the UI — see Phase 6.
                "appLogoUrl" to app.appLogoUrl,
                "iconBase64" to app.iconBase64,
            )
        }
    }

    // --------------------------------------------------------------------- launch

    private fun submitDirect(activity: Activity, call: MethodCall, result: MethodChannel.Result) {
        val keyId = call.argument<String>("keyId")
        val options = call.argument<Map<String, Any?>>("options")

        if (keyId.isNullOrEmpty() || options.isNullOrEmpty()) {
            result.error("UPI_BAD_ARGS", "keyId and options are required", null)
            return
        }

        // Claimed SYNCHRONOUSLY, before anything can suspend.
        attemptId += 1
        val thisAttempt = attemptId
        val answered = AtomicBoolean(false)

        fun finish(block: () -> Unit) {
            // Success always honoured; a stale FAILURE always ignored (D17). Asymmetric on
            // purpose: dropping a real success costs a paid user their entitlement.
            if (thisAttempt != attemptId) return
            if (!answered.compareAndSet(false, true)) return
            main.post {
                // Deliberately NOT tearing down: the SDK/WebView stay cached so a retry
                // does not pay the construction cost again. Correctness comes from
                // ensureReady()'s staleness check, not from destroying them.
                block()
            }
        }

        try {
            ensureReady(activity, keyId)
            val rzp = razorpay ?: throw IllegalStateException("Razorpay unavailable")

            val payload = JSONObject()
            options.forEach { (k, v) -> if (v != null) payload.put(k, v) }

            rzp.submit(
                payload,
                object : PaymentResultWithDataListener {
                    override fun onPaymentSuccess(paymentId: String?, data: PaymentData?) {
                        finish {
                            result.success(
                                mapOf(
                                    "status" to "success",
                                    "paymentId" to (paymentId ?: data?.paymentId),
                                    "signature" to data?.signature,
                                    "orderId" to data?.orderId,
                                    "raw" to data?.data?.toString(),
                                ),
                            )
                        }
                    }

                    override fun onPaymentError(code: Int, description: String?, data: PaymentData?) {
                        finish {
                            result.success(
                                mapOf(
                                    "status" to if (code == BaseRazorpay.PAYMENT_CANCELED) "cancelled" else "error",
                                    "code" to code,
                                    "message" to description,
                                    "paymentId" to data?.paymentId,
                                    "raw" to data?.data?.toString(),
                                ),
                            )
                        }
                    }
                },
            )
        } catch (e: Throwable) {
            finish { result.error("UPI_SUBMIT_FAILED", e.message, null) }
        }
    }

    /**
     * Forwarded from MainActivity.onActivityResult. A UPI app returns through the ACTIVITY,
     * not the SDK — without this the payment is never resolved and the user is stranded on
     * a disabled CTA having already paid.
     */
    fun forwardActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        razorpay?.onActivityResult(requestCode, resultCode, data)
    }

    /**
     * Geometry is load-bearing: 1x1, alpha 0, translated far off-screen — NEVER View.GONE
     * or zero-size. GONE views skip layout, and some OEM WebView builds suspend JavaScript
     * inside them, which stalls the handshake and hangs the payment with no error.
     */
    private fun attachHandshakeView(activity: Activity, rzp: Razorpay) {
        val view = WebView(activity)
        view.settings.javaScriptEnabled = true
        view.setScrollContainer(false)
        view.alpha = 0f
        view.translationX = -10_000f
        (activity.findViewById<ViewGroup>(android.R.id.content))?.addView(
            view,
            FrameLayout.LayoutParams(1, 1),
        )
        handshakeView = view
        rzp.setWebView(view)
    }

    private fun teardown() {
        handshakeView?.let { view ->
            (view.parent as? ViewGroup)?.removeView(view)
            view.destroy()
        }
        handshakeView = null
        runCatching { razorpay?.reset() }
        razorpay = null
        ownerRef = null
    }
}