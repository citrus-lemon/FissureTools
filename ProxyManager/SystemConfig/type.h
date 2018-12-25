#import <Foundation/Foundation.h>
#import <ruby/ruby.h>

VALUE nsid2rb(id value);
VALUE nsstr2rb(NSString *str);
VALUE nsarr2rb(NSArray *arr);
VALUE nsnum2rb(NSNumber *num);
VALUE nsdic2rb(NSDictionary *dict);

id rb2id(VALUE obj);