
#import "StepperObject.h"

@implementation StepperObject

@synthesize stepperValue=_stepperValue, delegate;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _stepperValue=0;
    }
    return self;
}

-(float) stepperValue{
    return _stepperValue;
}

-(void) setStepperValue:(float)stepperValue{
    _stepperValue=stepperValue;
    [delegate stepperValueChanged:(int) stepperValue];
    
}



@end
