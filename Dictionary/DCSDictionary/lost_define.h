#include <Foundation/Foundation.h>

#ifndef fissure_dictionary_lost_define_h
#define fissure_dictionary_lost_define_h

CFSetRef DCSGetActiveDictionaries(void);
CFSetRef DCSCopyAvailableDictionaries(void);
CFTypeRef DCSDictionaryGetAssetObj(DCSDictionaryRef dictID);
CFURLRef DCSDictionaryGetBaseURL(DCSDictionaryRef dictID);
CFStringRef DCSDictionaryGetIdentifier(DCSDictionaryRef dictID);
CFTypeRef DCSDictionaryGetLanguages(DCSDictionaryRef dictID);
CFStringRef DCSDictionaryGetName(DCSDictionaryRef dictID);
CFTypeRef DCSDictionaryGetParentDictionary(DCSDictionaryRef dictID);
CFTypeRef DCSDictionaryGetPreference(DCSDictionaryRef dictID);
CFTypeRef DCSDictionaryGetPreferenceHTML(DCSDictionaryRef dictID);
CFStringRef DCSDictionaryGetPrimaryLanguage(DCSDictionaryRef dictID);
CFStringRef DCSDictionaryGetShortName(DCSDictionaryRef dictID);
CFURLRef DCSDictionaryGetStyleSheetURL(DCSDictionaryRef dictID);
CFTypeRef DCSDictionaryGetSubDictionaries(DCSDictionaryRef dictID);
CFTypeID DCSDictionaryGetTypeID();
CFURLRef DCSDictionaryGetURL(DCSDictionaryRef dictID);

#endif /* fissure_dictionary_lost_define_h */
