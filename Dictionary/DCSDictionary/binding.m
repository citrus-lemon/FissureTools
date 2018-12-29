#include "lost_define.h"
#include "type.h"
#import <Foundation/Foundation.h>
#import <ruby/ruby.h>

VALUE m_dcs, c_dic, c_rec;

#pragma mark header

VALUE dic_from_ref(DCSDictionaryRef ref);
VALUE rec_from_ref(DCSRecordRef ref);

#pragma mark binding DCSDictionary

void dic_free(void *data) { free(data); }

size_t dic_size(const void *data) { return sizeof(DCSDictionaryRef); }

static const rb_data_type_t dic_type = {
    .wrap_struct_name = "DCSDictionary",
    .function =
        {
            .dmark = NULL,
            .dfree = dic_free,
            .dsize = dic_size,
        },
    .data = NULL,
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

VALUE dic_from_ref(DCSDictionaryRef ref) {
  VALUE dic = rb_class_new_instance(0, NULL, c_dic);
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(dic, DCSDictionaryRef, &dic_type, dicp);
  *dicp = ref;
  return dic;
}

VALUE dic_alloc(VALUE self) {
  DCSDictionaryRef *data = malloc(sizeof(DCSDictionaryRef));
  *data = NULL;
  return TypedData_Wrap_Struct(self, &dic_type, data);
}

VALUE dic_init(VALUE self) { return self; }

VALUE r_getActiveDictionaries(VALUE self) {
  CFSetRef dics = DCSGetActiveDictionaries();
  CFIndex c = CFSetGetCount(dics);
  DCSDictionaryRef dicrefs[c];
  CFSetGetValues(dics, (const void **)dicrefs);
  VALUE rbarr = rb_ary_new();
  for (CFIndex i = 0; i < c; i++) {
    rb_ary_push(rbarr, dic_from_ref(dicrefs[i]));
  }
  return rbarr;
}

VALUE r_copyAvailableDictionaries(VALUE self) {
  CFSetRef dics = DCSCopyAvailableDictionaries();
  CFIndex c = CFSetGetCount(dics);
  DCSDictionaryRef dicrefs[c];
  CFSetGetValues(dics, (const void **)dicrefs);
  VALUE rbarr = rb_ary_new();
  for (CFIndex i = 0; i < c; i++) {
    rb_ary_push(rbarr, dic_from_ref(dicrefs[i]));
  }
  return rbarr;
}

VALUE dic_identifier(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFStringRef identifier = DCSDictionaryGetIdentifier(*dicp);
  return cfstr2rb(identifier);
}

VALUE dic_name(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFStringRef name = DCSDictionaryGetName(*dicp);
  return cfstr2rb(name);
}

VALUE dic_short_name(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFStringRef shortname = DCSDictionaryGetShortName(*dicp);
  return cfstr2rb(shortname);
}

VALUE dic_primary_language(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFStringRef pl = DCSDictionaryGetPrimaryLanguage(*dicp);
  return cfstr2rb(pl);
}

VALUE dic_url(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFURLRef url = DCSDictionaryGetURL(*dicp);
  if (!url)
    return Qnil;
  return cfstr2rb(CFURLGetString(url));
}

VALUE dic_base_url(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFURLRef url = DCSDictionaryGetBaseURL(*dicp);
  if (!url)
    return Qnil;
  return cfstr2rb(CFURLGetString(url));
}

VALUE dic_stylesheet_url(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFURLRef url = DCSDictionaryGetStyleSheetURL(*dicp);
  if (!url)
    return Qnil;
  return cfstr2rb(CFURLGetString(url));
}

VALUE dic_asset_obj(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFTypeRef v = DCSDictionaryGetAssetObj(*dicp);
  return cftype2rb(v);
}

VALUE dic_languages(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFTypeRef v = DCSDictionaryGetLanguages(*dicp);
  return cftype2rb(v);
}

VALUE dic_parent_dictionary(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFTypeRef v = DCSDictionaryGetParentDictionary(*dicp);
  return cftype2rb(v);
}

VALUE dic_preference(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFTypeRef v = DCSDictionaryGetPreference(*dicp);
  return cftype2rb(v);
}

VALUE dic_preference_html(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFTypeRef v = DCSDictionaryGetPreferenceHTML(*dicp);
  return cftype2rb(v);
}

VALUE dic_sub_dictionaries(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFArrayRef v = DCSDictionaryGetSubDictionaries(*dicp);
#ifndef CFTYPE_MAP_DCS_DICTIONARY
  VALUE rbarr = rb_ary_new();
  if (!v)
    return rbarr;
  CFIndex c = CFArrayGetCount(v);
  CFTypeRef list[c];
  CFArrayGetValues(v, CFRangeMake(0, c), list);
  for (CFIndex i = 0; i < c; i++) {
    rb_ary_push(rbarr, dic_from_ref(list[i]));
  }
  return rbarr;
#else
  return cftype2rb(v);
#endif
}

VALUE dic_text_definition(VALUE self, VALUE text) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  NSString *word = [NSString stringWithUTF8String:StringValueCStr(text)];
  CFStringRef definition = DCSCopyTextDefinition(
      *dicp, (__bridge CFStringRef)word, CFRangeMake(0, word.length));
  return cfstr2rb(definition);
}

VALUE dic_definitions(VALUE self, VALUE text) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  NSString *word = [NSString stringWithUTF8String:StringValueCStr(text)];
  CFTypeRef definitions = DCSCopyDefinitions(*dicp, (__bridge CFStringRef)word,
                                             CFRangeMake(0, word.length));
  return cftype2rb(definitions);
}

VALUE dic_definition_records(VALUE self, VALUE text) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  NSString *word = [NSString stringWithUTF8String:StringValueCStr(text)];
  CFArrayRef v = DCSCopyDefinitionRecords(*dicp, (__bridge CFStringRef)word,
                                          CFRangeMake(0, word.length));
  VALUE rbarr = rb_ary_new();
  if (!v)
    return rbarr;
  CFIndex c = CFArrayGetCount(v);
  CFTypeRef list[c];
  CFArrayGetValues(v, CFRangeMake(0, c), list);
  for (CFIndex i = 0; i < c; i++) {
    rb_ary_push(rbarr, rec_from_ref(list[i]));
  }
  return rbarr;
}

VALUE dic_search(VALUE self, VALUE text) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  NSString *word = [NSString stringWithUTF8String:StringValueCStr(text)];
  CFArrayRef v = DCSCopyRecordsForSearchString(
      *dicp, (__bridge CFStringRef)word, CFRangeMake(0, word.length));

  VALUE rbarr = rb_ary_new();
  if (!v)
    return rbarr;
  CFIndex c = CFArrayGetCount(v);
  CFTypeRef list[c];
  CFArrayGetValues(v, CFRangeMake(0, c), list);
  for (CFIndex i = 0; i < c; i++) {
    rb_ary_push(rbarr, rec_from_ref(list[i]));
  }
  return rbarr;
}

VALUE dic_inspect(VALUE self) {
  VALUE sn = rb_funcall(self, rb_intern("short_name"), 0);
  if (sn == Qnil) {
    sn = rb_funcall(self, rb_intern("identifier"), 0);
    if (sn == Qnil)
      return rb_str_new_cstr("#<DCSDictionary>");
    sn = rb_funcall(sn, rb_intern("sub"), 2,
                    rb_str_new_cstr("com.apple.dictionary."),
                    rb_str_new_cstr(""));
    return rb_str_cat2(rb_str_concat(rb_str_new_cstr("#<DCSDictionary("), sn),
                       ")>");
  }
  return rb_str_cat2(rb_str_concat(rb_str_new_cstr("#<DCSDictionary["), sn),
                     "]>");
}

VALUE dic_equal(VALUE this, VALUE that) {
  if (!rb_obj_is_instance_of(that, rb_class_of(this))) {
    return Qfalse;
  }
  DCSDictionaryRef *dicp, *dicp2;
  TypedData_Get_Struct(this, DCSDictionaryRef, &dic_type, dicp);
  TypedData_Get_Struct(that, DCSDictionaryRef, &dic_type, dicp2);
  return (*dicp == *dicp2) ? Qtrue : Qfalse;
}

#pragma mark binding DCSRecord

void rec_free(void *data) { free(data); }

size_t rec_size(const void *data) { return sizeof(DCSRecordRef); }

static const rb_data_type_t rec_type = {
    .wrap_struct_name = "DCSRecord",
    .function =
        {
            .dmark = NULL,
            .dfree = rec_free,
            .dsize = rec_size,
        },
    .data = NULL,
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

VALUE rec_from_ref(DCSRecordRef ref) {
  VALUE rec = rb_class_new_instance(0, NULL, c_rec);
  DCSRecordRef *recp;
  TypedData_Get_Struct(rec, DCSRecordRef, &rec_type, recp);
  *recp = ref;
  return rec;
}

VALUE rec_alloc(VALUE self) {
  DCSRecordRef *data = malloc(sizeof(DCSRecordRef));
  *data = NULL;
  return TypedData_Wrap_Struct(self, &rec_type, data);
}

VALUE rec_init(VALUE self) { return self; }

VALUE rec_data(VALUE self) {
  DCSRecordRef *recp;
  TypedData_Get_Struct(self, DCSRecordRef, &rec_type, recp);
  CFTypeRef v = DCSRecordCopyData(*recp);
  return cftype2rb(v);
}

VALUE rec_data_url(VALUE self) {
  DCSRecordRef *recp;
  TypedData_Get_Struct(self, DCSRecordRef, &rec_type, recp);
  CFTypeRef v = DCSRecordCopyDataURL(*recp);
  return cftype2rb(v);
}

VALUE rec_definition(VALUE self) {
  DCSRecordRef *recp;
  TypedData_Get_Struct(self, DCSRecordRef, &rec_type, recp);
  CFTypeRef v = DCSRecordCopyDefinition(*recp);
  return cftype2rb(v);
}

// Error: EXC_BAD_ACCESS
// VALUE rec_text_elements(VALUE self) {
//   DCSRecordRef *recp;
//   TypedData_Get_Struct(self, DCSRecordRef, &rec_type, recp);
//   CFTypeRef v = DCSRecordCopyTextElements(*recp);
//   return cftype2rb(v);
// }

VALUE rec_anchor(VALUE self) {
  DCSRecordRef *recp;
  TypedData_Get_Struct(self, DCSRecordRef, &rec_type, recp);
  CFTypeRef v = DCSRecordGetAnchor(*recp);
  return cftype2rb(v);
}

VALUE rec_associated_obj(VALUE self) {
  DCSRecordRef *recp;
  TypedData_Get_Struct(self, DCSRecordRef, &rec_type, recp);
  CFTypeRef v = DCSRecordGetAssociatedObj(*recp);
  return cftype2rb(v);
}

VALUE rec_dictionary(VALUE self) {
  DCSRecordRef *recp;
  TypedData_Get_Struct(self, DCSRecordRef, &rec_type, recp);
  DCSDictionaryRef v = DCSRecordGetDictionary(*recp);
  if (!v)
    return Qnil;
  return dic_from_ref(v);
}

VALUE rec_headword(VALUE self) {
  DCSRecordRef *recp;
  TypedData_Get_Struct(self, DCSRecordRef, &rec_type, recp);
  CFTypeRef v = DCSRecordGetHeadword(*recp);
  return cftype2rb(v);
}

VALUE rec_raw_headword(VALUE self) {
  DCSRecordRef *recp;
  TypedData_Get_Struct(self, DCSRecordRef, &rec_type, recp);
  CFTypeRef v = DCSRecordGetRawHeadword(*recp);
  return cftype2rb(v);
}

VALUE rec_string(VALUE self) {
  DCSRecordRef *recp;
  TypedData_Get_Struct(self, DCSRecordRef, &rec_type, recp);
  CFTypeRef v = DCSRecordGetString(*recp);
  return cftype2rb(v);
}

VALUE rec_sub_dictionary(VALUE self) {
  DCSRecordRef *recp;
  TypedData_Get_Struct(self, DCSRecordRef, &rec_type, recp);
  CFTypeRef v = DCSRecordGetSubDictionary(*recp);
  return cftype2rb(v);
}

VALUE rec_supplemental_headword(VALUE self) {
  DCSRecordRef *recp;
  TypedData_Get_Struct(self, DCSRecordRef, &rec_type, recp);
  CFTypeRef v = DCSRecordGetSupplementalHeadword(*recp);
  return cftype2rb(v);
}

VALUE rec_title(VALUE self) {
  DCSRecordRef *recp;
  TypedData_Get_Struct(self, DCSRecordRef, &rec_type, recp);
  CFTypeRef v = DCSRecordGetTitle(*recp);
  return cftype2rb(v);
}

void Init_binding() {
  m_dcs = rb_define_module("DictionaryServices");
  c_dic = rb_define_class_under(m_dcs, "DCSDictionary", rb_cData);
  rb_define_alloc_func(c_dic, dic_alloc);
  rb_define_method(c_dic, "initialize", dic_init, 0);
  rb_define_method(c_dic, "name", dic_name, 0);
  rb_define_method(c_dic, "short_name", dic_short_name, 0);
  rb_define_method(c_dic, "primary_language", dic_primary_language, 0);
  rb_define_method(c_dic, "identifier", dic_identifier, 0);
  rb_define_method(c_dic, "url", dic_url, 0);
  rb_define_method(c_dic, "base_url", dic_base_url, 0);
  rb_define_method(c_dic, "stylesheet_url", dic_stylesheet_url, 0);
  rb_define_method(c_dic, "asset_obj", dic_asset_obj, 0);
  rb_define_method(c_dic, "languages", dic_languages, 0);
  rb_define_method(c_dic, "parent_dictionary", dic_parent_dictionary, 0);
  rb_define_method(c_dic, "preference", dic_preference, 0);
  rb_define_method(c_dic, "preference_html", dic_preference_html, 0);
  rb_define_method(c_dic, "sub_dictionaries", dic_sub_dictionaries, 0);
  rb_define_method(c_dic, "text_definition", dic_text_definition, 1);
  rb_define_method(c_dic, "definitions", dic_definitions, 1);
  rb_define_method(c_dic, "definition_records", dic_definition_records, 1);
  rb_define_method(c_dic, "search", dic_search, 1);
  rb_define_method(c_dic, "inspect", dic_inspect, 0);
  rb_define_method(c_dic, "==", dic_equal, 1);

  c_rec = rb_define_class_under(m_dcs, "DCSRecord", rb_cData);
  rb_define_alloc_func(c_rec, rec_alloc);
  rb_define_method(c_rec, "initialize", rec_init, 0);
  rb_define_method(c_rec, "data", rec_data, 0);
  rb_define_method(c_rec, "data_url", rec_data_url, 0);
  rb_define_method(c_rec, "definition", rec_definition, 0);
  // Error: EXC_BAD_ACCESS
  // rb_define_method(c_rec, "text_elements", rec_text_elements, 0);
  rb_define_method(c_rec, "anchor", rec_anchor, 0);
  rb_define_method(c_rec, "associated_obj", rec_associated_obj, 0);
  rb_define_method(c_rec, "dictionary", rec_dictionary, 0);
  rb_define_method(c_rec, "headword", rec_headword, 0);
  rb_define_method(c_rec, "raw_headword", rec_raw_headword, 0);
  rb_define_method(c_rec, "string", rec_string, 0);
  rb_define_method(c_rec, "sub_dictionary", rec_sub_dictionary, 0);
  rb_define_method(c_rec, "supplemental_headword", rec_supplemental_headword,
                   0);
  rb_define_method(c_rec, "title", rec_title, 0);

  rb_define_module_function(m_dcs, "getActiveDictionaries",
                            r_getActiveDictionaries, 0);
  rb_define_module_function(m_dcs, "copyAvailableDictionaries",
                            r_copyAvailableDictionaries, 0);
}
