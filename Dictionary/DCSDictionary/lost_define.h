#include <Foundation/Foundation.h>

#ifndef fissure_dictionary_lost_define_h
#define fissure_dictionary_lost_define_h

typedef const struct CF_BRIDGED_TYPE(id) __DCSRecord *DCSRecordRef;

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
CFArrayRef DCSCopyDefinitionRecords(DCSDictionaryRef, CFStringRef, CFRange);
CFArrayRef DCSCopyRecordsForSearchString(DCSDictionaryRef, CFStringRef, int,
                                         int);
CFStringRef DCSRecordCopyData(DCSRecordRef);
CFURLRef DCSRecordCopyDataURL(DCSRecordRef);
CFStringRef DCSRecordCopyDefinition(DCSRecordRef);
CFTypeRef DCSRecordCopyTextElements(DCSRecordRef);
CFTypeRef DCSRecordGetAnchor(DCSRecordRef);
CFTypeRef DCSRecordGetAssociatedObj(DCSRecordRef);
CFTypeRef DCSRecordGetDictionary(DCSRecordRef);
CFStringRef DCSRecordGetHeadword(DCSRecordRef);
CFStringRef DCSRecordGetRawHeadword(DCSRecordRef);
CFStringRef DCSRecordGetString(DCSRecordRef);
CFTypeRef DCSRecordGetSubDictionary(DCSRecordRef);
CFTypeRef DCSRecordGetSupplementalHeadword(DCSRecordRef);
CFTypeRef DCSRecordGetTitle(DCSRecordRef);

#endif /* fissure_dictionary_lost_define_h */
