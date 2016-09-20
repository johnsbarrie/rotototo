#import <Cocoa/Cocoa.h>
@protocol StepperObjectDelegate
-(void) stepperValueChanged:(int)value;
@end

@interface StepperObject : NSObject{
    float _stepperValue;
    id <StepperObjectDelegate> delegate;
}

@property (retain) id <StepperObjectDelegate> delegate;
@property (assign) float stepperValue;
@end
