import 'package:get/get_navigation/src/root/internacionalization.dart';
import 'package:posterapp/resource/values/languages/tamil.dart';
import 'package:posterapp/resource/values/languages/te.dart';

import 'Bengali.dart';
import 'en.dart';
import 'gu.dart';
import 'hi.dart';
import 'kannada.dart';
import 'marathi.dart';
import 'odiya.dart';

class Languages extends Translations {
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys =>
      {'en_US': enUsTranslation,
        'hi_In': hiINTranslation,
        'gu_In':guINTranslation,
        'te_In':teINTranslation,
        'mr_In':mrUsTranslation,
        'kn_In':kannadaTranslation,
        'bn_In':bnInTranslation,
        'ta_In':taInTranslation,
        'or_In':orInTranslation,
      };
}
