#include <Foundation/Foundation.h>

#ifndef fissure_dictionary_lost_define_h
#define fissure_dictionary_lost_define_h

CFSetRef DCSGetActiveDictionaries(void);
CFSetRef DCSCopyAvailableDictionaries(void);
CFTypeRef DCSDictionaryGetAssetObj(DCSDictionaryRef);
CFURLRef DCSDictionaryGetBaseURL(DCSDictionaryRef);
CFStringRef DCSDictionaryGetIdentifier(DCSDictionaryRef);
CFTypeRef DCSDictionaryGetLanguages(DCSDictionaryRef);
CFStringRef DCSDictionaryGetName(DCSDictionaryRef);
CFTypeRef DCSDictionaryGetParentDictionary(DCSDictionaryRef);
CFTypeRef DCSDictionaryGetPreference(DCSDictionaryRef);
CFTypeRef DCSDictionaryGetPreferenceHTML(DCSDictionaryRef);
CFStringRef DCSDictionaryGetPrimaryLanguage(DCSDictionaryRef);
CFStringRef DCSDictionaryGetShortName(DCSDictionaryRef);
CFURLRef DCSDictionaryGetStyleSheetURL(DCSDictionaryRef);
CFTypeRef DCSDictionaryGetSubDictionaries(DCSDictionaryRef);
CFTypeID DCSDictionaryGetTypeID(void);
CFURLRef DCSDictionaryGetURL(DCSDictionaryRef);
CFArrayRef DCSCopyDefinitions(DCSDictionaryRef, CFStringRef, CFRange);

#endif /* fissure_dictionary_lost_define_h */
