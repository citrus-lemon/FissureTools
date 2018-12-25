#import "type.h"
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <ruby/ruby.h>

static SCPreferencesRef prefRef = NULL;
static AuthorizationRef authRef;
static AuthorizationFlags authFlags;

VALUE get_permission(VALUE self) {
  if (prefRef) {
    return Qtrue;
  }
  authFlags = kAuthorizationFlagDefaults | kAuthorizationFlagExtendRights |
              kAuthorizationFlagInteractionAllowed |
              kAuthorizationFlagPreAuthorize;
  OSStatus authErr = AuthorizationCreate(nil, kAuthorizationEmptyEnvironment,
                                         authFlags, &authRef);
  if (authErr != noErr) {
    authRef = nil;
    rb_raise(rb_eRuntimeError, "Error when create authorization");
    return Qfalse;
  } else {
    if (authRef == NULL) {
      rb_raise(
          rb_eRuntimeError,
          "No authorization has been granted to modify network configuration");
    }
    prefRef = SCPreferencesCreateWithAuthorization(nil, CFSTR("ProxyManager"),
                                                   nil, authRef);
    return Qtrue;
  }
}

VALUE apply_change(VALUE self) {
  SCPreferencesCommitChanges(prefRef);
  SCPreferencesApplyChanges(prefRef);
  SCPreferencesSynchronize(prefRef);

  return Qnil;
}

VALUE release_auth(VALUE self) {
  AuthorizationFree(authRef, kAuthorizationFlagDefaults);
  prefRef = NULL;
  return Qnil;
}

VALUE change_config(VALUE self, VALUE path, VALUE value) {
  VALUE permission = rb_funcall(self, rb_intern("get_permission"), 0);
  if (permission != Qtrue) {
    rb_raise(rb_eRuntimeError, "cannot get permission");
  }
  Check_Type(path, T_STRING);
  return SCPreferencesPathSetValue(prefRef, (__bridge CFStringRef)rb2id(path),
                                   (__bridge CFDictionaryRef)rb2id(value))
             ? Qtrue
             : Qfalse;
}

VALUE get_proxy(VALUE self) {
  VALUE permission = rb_funcall(self, rb_intern("get_permission"), 0);
  if (permission != Qtrue) {
    rb_raise(rb_eRuntimeError, "cannot get permission");
  }
  NSDictionary *sets = (NSDictionary *)CFBridgingRelease(
      SCPreferencesGetValue(prefRef, kSCPrefNetworkServices));

  return nsdic2rb(sets);
}

// VALUE rb2rb(VALUE self, VALUE obj) { return nsid2rb(rb2id(obj)); }

void Init_binding() {
  VALUE m_pm = rb_define_module("ProxyManager");
  VALUE m_sc = rb_define_module_under(m_pm, "SystemConfig");

#define ADD_CONST(n, v)                                                        \
  rb_define_const(                                                             \
      m_sc, n,                                                                 \
      rb_str_new_cstr(CFStringGetCStringPtr(v, kCFStringEncodingUTF8)));
#include "constant.h"
#undef ADD_CONST

  rb_define_module_function(m_sc, "get_permission", get_permission, 0);
  rb_define_module_function(m_sc, "apply_change", apply_change, 0);
  rb_define_module_function(m_sc, "release_auth", release_auth, 0);
  rb_define_module_function(m_sc, "get_proxy", get_proxy, 0);
  rb_define_module_function(m_sc, "change_config", change_config, 2);
}
