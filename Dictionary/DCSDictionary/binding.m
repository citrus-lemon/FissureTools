#include "lost_define.h"
#include "type.h"
#import <Foundation/Foundation.h>
#import <ruby/ruby.h>

#pragma mark ruby binding

size_t dic_size(const void *data) { return sizeof(DCSDictionaryRef); }

static const rb_data_type_t dic_type = {
    .wrap_struct_name = "DCSDictionary",
    .function =
        {
            .dmark = NULL,
            .dfree = NULL,
            .dsize = dic_size,
        },
    .data = NULL,
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

VALUE dic_alloc(VALUE self) {
  DCSDictionaryRef *data = malloc(sizeof(DCSDictionaryRef));
  *data = NULL;
  return TypedData_Wrap_Struct(self, &dic_type, data);
}

VALUE dic_init(VALUE self) { return self; }

VALUE r_getActiveDictionaries(VALUE self) {
  CFSetRef dics = DCSGetActiveDictionaries();
  VALUE c_dic = rb_const_get(self, rb_intern("DCSDictionary"));
  CFIndex c = CFSetGetCount(dics);
  DCSDictionaryRef dicrefs[c];
  CFSetGetValues(dics, (const void **)dicrefs);
  VALUE rbarr = rb_ary_new();
  for (CFIndex i = 0; i < c; i++) {
    VALUE dic = rb_class_new_instance(0, NULL, c_dic);
    rb_ary_push(rbarr, dic);
    DCSDictionaryRef *dicp;
    TypedData_Get_Struct(dic, DCSDictionaryRef, &dic_type, dicp);
    *dicp = dicrefs[i];
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
  CFURLRef pl = DCSDictionaryGetURL(*dicp);
  return cfstr2rb(CFURLGetString(pl));
}

VALUE dic_base_url(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFURLRef pl = DCSDictionaryGetBaseURL(*dicp);
  return cfstr2rb(CFURLGetString(pl));
}

VALUE dic_stylesheet_url(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFURLRef pl = DCSDictionaryGetStyleSheetURL(*dicp);
  return cfstr2rb(CFURLGetString(pl));
}

VALUE dic_asset_obj(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFTypeRef pl = DCSDictionaryGetAssetObj(*dicp);
  return cftype2rb(pl);
}

VALUE dic_languages(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFTypeRef pl = DCSDictionaryGetLanguages(*dicp);
  return cftype2rb(pl);
}

VALUE dic_parent_dictionary(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFTypeRef pl = DCSDictionaryGetParentDictionary(*dicp);
  return cftype2rb(pl);
}

VALUE dic_preference(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFTypeRef pl = DCSDictionaryGetPreference(*dicp);
  return cftype2rb(pl);
}

VALUE dic_preference_html(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFTypeRef pl = DCSDictionaryGetPreferenceHTML(*dicp);
  return cftype2rb(pl);
}

VALUE dic_sub_dictionaries(VALUE self) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  CFTypeRef pl = DCSDictionaryGetSubDictionaries(*dicp);
  return cftype2rb(pl);
}

VALUE dic_text_definition(VALUE self, VALUE text) {
  DCSDictionaryRef *dicp;
  TypedData_Get_Struct(self, DCSDictionaryRef, &dic_type, dicp);
  NSString *word = [NSString stringWithUTF8String:StringValueCStr(text)];
  CFStringRef definition = DCSCopyTextDefinition(
      *dicp, (__bridge CFStringRef)word, CFRangeMake(0, word.length));
  return cfstr2rb(definition);
}

void Init_binding() {
  VALUE m_dcs = rb_define_module("DictionaryServices");
  VALUE c_dic = rb_define_class_under(m_dcs, "DCSDictionary", rb_cData);
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
  rb_define_module_function(m_dcs, "getActiveDictionaries",
                            r_getActiveDictionaries, 0);
}
