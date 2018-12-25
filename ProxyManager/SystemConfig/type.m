#include "type.h"

VALUE nsstr2rb(NSString *str) { return rb_str_new_cstr([str UTF8String]); }

VALUE nsarr2rb(NSArray *arr) {
  VALUE rbarr = rb_ary_new();
  for (id obj in arr) {
    rb_ary_push(rbarr, nsid2rb(obj));
  }
  return rbarr;
}

VALUE nsnum2rb(NSNumber *num) {
  // return ID2SYM(rb_intern([num objCType]));
  // return INT2NUM(CFNumberGetType((CFNumberRef)num));
  switch (CFNumberGetType((CFNumberRef)num)) {
  case kCFNumberCharType:
  case kCFNumberShortType:
  case kCFNumberIntType:
  case kCFNumberSInt8Type:
  case kCFNumberSInt16Type:
  case kCFNumberSInt32Type:
  case kCFNumberCFIndexType:
  case kCFNumberNSIntegerType:
    return INT2NUM([num intValue]);
  case kCFNumberSInt64Type:
    return LONG2NUM([num longValue]);
  case kCFNumberFloat32Type:
  case kCFNumberFloat64Type:
  case kCFNumberFloatType:
  case kCFNumberCGFloatType:
  case kCFNumberDoubleType:
    return DBL2NUM([num doubleValue]);
  case kCFNumberLongLongType:
    return LL2NUM([num longLongValue]);
  default:
    return Qnil;
  }
}

VALUE nsdic2rb(NSDictionary *dict) {
  // only support key is string
  VALUE rbdic = rb_hash_new();
  for (NSString *key in [dict allKeys]) {
    id value = [dict objectForKey:key];
    rb_hash_aset(rbdic, nsstr2rb(key), nsid2rb(value));
  }
  return rbdic;
}

VALUE nsid2rb(id value) {
  // only support NSDictionary, NSArray, NSString, NSNumber
  if ([value isKindOfClass:[NSString class]]) {
    return nsstr2rb(value);
  } else if ([value isKindOfClass:[NSDictionary class]]) {
    return nsdic2rb(value);
  } else if ([value isKindOfClass:[NSArray class]]) {
    return nsarr2rb(value);
  } else if ([value isKindOfClass:[NSNumber class]]) {
    return nsnum2rb(value);
  } else if ([value isKindOfClass:[NSNull class]]) {
    return Qnil;
  } else {
    return ID2SYM(rb_intern([[value className] UTF8String]));
  }
}

id rb2id(VALUE obj) {
  // ruby to NSObject
  switch (TYPE(obj)) {
  case T_NIL:
    return [NSNull null];
  case T_TRUE:
    return [NSNumber numberWithBool:true];
  case T_FALSE:
    return [NSNumber numberWithBool:false];
  case T_FIXNUM:
    return [NSNumber numberWithInt:NUM2INT(obj)];
  case T_FLOAT:
    return [NSNumber numberWithDouble:NUM2DBL(obj)];
  case T_STRING:
    return [NSString stringWithUTF8String:StringValueCStr(obj)];
  case T_ARRAY: {
    long len = rb_array_len(obj);
    const VALUE *vals = rb_array_const_ptr(obj);
    id arr[len];
    for (long i = 0; i < len; i++) {
      arr[i] = rb2id(vals[i]);
    }
    return [NSArray arrayWithObjects:arr count:len];
  }
  case T_HASH: {
    VALUE h2a = rb_funcall(obj, rb_intern("to_a"), 0);
    long len = rb_array_len(h2a);
    id keys[len];
    id vals[len];
    for (long i = 0; i < len; i++) {
      VALUE key = rb_ary_entry(rb_ary_entry(h2a, i), 0);
      if (!RB_TYPE_P(key, T_STRING)) {
        rb_raise(rb_eArgError, "key must be string");
      }
      keys[i] = rb2id(key);
      vals[i] = rb2id(rb_ary_entry(rb_ary_entry(h2a, i), 1));
    }
    return [NSDictionary dictionaryWithObjects:vals forKeys:keys count:len];
  }
  default:
    rb_raise(rb_eArgError, "%s is not supported as value type",
             rb_obj_classname(obj));
  }
}
