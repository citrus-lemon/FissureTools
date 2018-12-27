#include "type.h"

#ifdef CFTYPE_MAP_DCS_DICTIONARY
CFTypeID DCSDictionaryGetTypeID();
VALUE dic_from_ref(DCSDictionaryRef ref);
#endif

VALUE cftype2rb(CFTypeRef obj) {
  if (!obj)
    return Qnil;
  CFTypeID tid = CFGetTypeID(obj);
  if (tid == CFStringGetTypeID()) {
    return cfstr2rb(obj);
  } else if (tid == CFArrayGetTypeID()) {
    return cfarr2rb(obj);
  } else if (tid == CFDictionaryGetTypeID()) {
    return cfdic2rb(obj);
  } else if (tid == CFNumberGetTypeID()) {
    return cfnum2rb(obj);
  } else if (tid == CFNullGetTypeID()) {
    return Qnil;
  } else if (tid == CFBooleanGetTypeID()) {
    return cfbool2rb(obj);
  }
#ifdef CFTYPE_MAP_DCS_DICTIONARY
  else if (tid == DCSDictionaryGetTypeID()) {
    return dic_from_ref(obj);
  }
#endif
  else {
#ifndef CFTYPE_TO_STRING
    return rb_to_symbol(cfstr2rb(CFCopyTypeIDDescription(CFGetTypeID(obj))));
#else
    return cfstr2rb(CFCopyDescription(obj));
#endif
  }
}

VALUE cfstr2rb(CFStringRef acfstr) {
  if (!acfstr)
    return Qnil;
  CFIndex length = CFStringGetLength(acfstr);
  CFIndex maxSize =
      CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8) + 1;
  char str[maxSize];
  if (CFStringGetCString(acfstr, str, maxSize, kCFStringEncodingUTF8)) {
    return rb_utf8_str_new_cstr(str);
  } else {
    return Qnil;
  }
}

VALUE cfdic2rb(CFDictionaryRef acfdic) {
  if (!acfdic)
    return Qnil;
  CFIndex length = CFDictionaryGetCount(acfdic);
  CFTypeRef keys[length], values[length];
  CFDictionaryGetKeysAndValues(acfdic, keys, values);
  VALUE hash = rb_hash_new();
  for (CFIndex i = 0; i < length; i++) {
    rb_hash_aset(hash, cftype2rb(keys[i]), cftype2rb(values[i]));
  }
  return hash;
}

VALUE cfarr2rb(CFArrayRef acfarr) {
  CFIndex c = CFArrayGetCount(acfarr);
  CFTypeRef list[c];
  CFArrayGetValues(acfarr, CFRangeMake(0, c), list);
  VALUE rbarr = rb_ary_new();
  for (CFIndex i = 0; i < c; i++) {
    rb_ary_push(rbarr, cftype2rb(list[i]));
  }
  return rbarr;
}

VALUE cfnum2rb(CFNumberRef acfnum) {
  switch (CFNumberGetType(acfnum)) {
  case kCFNumberCharType:
  case kCFNumberShortType:
  case kCFNumberIntType:
  case kCFNumberSInt8Type:
  case kCFNumberSInt16Type:
  case kCFNumberSInt32Type:
  case kCFNumberNSIntegerType: {
    int num;
    CFNumberGetValue(acfnum, kCFNumberSInt32Type, &num);
    return INT2NUM(num);
  }
  case kCFNumberCFIndexType:
  case kCFNumberSInt64Type: {
    long num;
    CFNumberGetValue(acfnum, kCFNumberSInt64Type, &num);
    return LONG2NUM(num);
  }
  case kCFNumberFloat32Type:
  case kCFNumberFloat64Type:
  case kCFNumberFloatType:
  case kCFNumberCGFloatType:
  case kCFNumberDoubleType: {
    double num;
    CFNumberGetValue(acfnum, kCFNumberDoubleType, &num);
    return DBL2NUM(num);
  }
  case kCFNumberLongLongType: {
    long long num;
    CFNumberGetValue(acfnum, kCFNumberLongLongType, &num);
    return LL2NUM(num);
  }
  default:
    return Qnil;
  }
}

VALUE cfbool2rb(CFBooleanRef obj) {
  return CFBooleanGetValue(obj) ? Qtrue : Qfalse;
}
