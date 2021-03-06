//
//  ASOBounceButtonView.m
//  ASOAnimatedButton
//
//  Created by Agus Soedibjo on 8/2/14.
//  Copyright (c) 2014 Agus Soedibjo. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ASOBounceButtonView.h"
#import "ASOBounceButtonViewDelegate.h"

#define DEFAULT_ANIMATION_SPEED ((float) 0.1)
#define DEFAULT_ANIMATION_FADEOUT_DURATION ((float) 0.1)
#define DEFAULT_ANIMATION_BOUNCING_DISTANCE ((float) 0.6)

@interface ASOBounceButtonView()

@property (strong, nonatomic) NSMutableArray *bounceButtons;
@property (strong, nonatomic) NSMutableArray *bounceLabels;
@property (nonatomic) CGPoint startAnimationPoint;
@property (strong, readwrite, nonatomic) NSNumber *collapsedViewDuration;

@end

@implementation ASOBounceButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setAnimationStartFromHere:(CGRect)startingViewFrame
{
    [self layoutIfNeeded];
    self.startAnimationPoint = CGPointMake(startingViewFrame.origin.x + (startingViewFrame.size.width/2), startingViewFrame.origin.y + (startingViewFrame.size.height/2));
}

- (void)initBounceButtons
{
    self.bounceButtons = [[NSMutableArray alloc] init];
    
    // Set to default values
    self.speed = [NSNumber numberWithFloat:DEFAULT_ANIMATION_SPEED];
    self.fadeOutDuration = [NSNumber numberWithFloat:DEFAULT_ANIMATION_FADEOUT_DURATION];
    self.bouncingDistance = [NSNumber numberWithFloat:DEFAULT_ANIMATION_BOUNCING_DISTANCE];
}

- (void) didSelectBounceButtonFrom:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectBounceButtonAtIndex:)]) {
        [self.delegate didSelectBounceButtonAtIndex:[sender tag]];
    }
}

- (void)addBounceButton:(UIButton *)bounceButton
{
    if (!self.bounceButtons) {
        [self initBounceButtons];
    }
    
    [self.bounceButtons addObject:bounceButton];
    [[self.bounceButtons lastObject] setTag:[self.bounceButtons count] - 1];
    
    // Add control event to the last added bounce button
    [[self.bounceButtons lastObject] addTarget:self action:@selector(didSelectBounceButtonFrom:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addBounceButtons:(NSArray *)arrBounceButtons
{
    if (!self.bounceButtons) {
        [self initBounceButtons];
    }
    [self.bounceButtons addObjectsFromArray:arrBounceButtons];
    
    // Add control event to all of the bounce buttons
    for (int16_t idx = 0; idx < [self.bounceButtons count]; idx++) {
        [[self.bounceButtons objectAtIndex:idx] setTag:idx];
        [[self.bounceButtons objectAtIndex:idx] addTarget:self action:@selector(didSelectBounceButtonFrom:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)addBounceLabels:(NSArray *)arrBounceLabels
{
    if (!self.bounceLabels) {
        self.bounceLabels = [[NSMutableArray alloc] init];
    }
    [self.bounceLabels addObjectsFromArray:arrBounceLabels];
    
    for (int16_t idx = 0; idx < [self.bounceLabels count]; idx++) {
        [[self.bounceLabels objectAtIndex:idx] setTag:idx];
    }
}

- (CGPoint)bounceTargetPointWithStartPoint:(CGPoint)startPoint EndPoint:(CGPoint)endPoint
{
    float widthBounceTarget = [self.bouncingDistance floatValue] * (startPoint.x - endPoint.x);
    float heightBounceTarget = [self.bouncingDistance floatValue] * (startPoint.y - endPoint.y);
    
    CGPoint bounceTargetPoint = CGPointMake(endPoint.x - widthBounceTarget, endPoint.y - heightBounceTarget);
    
    return bounceTargetPoint;
}

- (void)expandWithAnimationStyle:(ASOAnimationStyle)animationStyle
{
    [self layoutIfNeeded];
    
    // Process and animates all the buttons
    CGPoint previousButtonPosition = CGPointZero;
    CGPoint currentButtonPosition = CGPointZero;
    CGPoint bouncePosition = CGPointZero;
    CGPoint previousLabelPosition = CGPointZero;
    CGPoint currentLabelPosition = CGPointZero;
    CGPoint labelBouncePosition = CGPointZero;
    int16_t startIdx = 0;
    
    for (int16_t item = 0; item < [self.bounceButtons count]; item++) {
        CGMutablePathRef thePath = CGPathCreateMutable();
        CGPathMoveToPoint(thePath, NULL, self.startAnimationPoint.x, self.startAnimationPoint.y);
        
        CGMutablePathRef labelPath = CGPathCreateMutable();
        CGPathMoveToPoint(labelPath, NULL, self.startAnimationPoint.x, self.startAnimationPoint.y);
        
        previousButtonPosition = CGPathGetCurrentPoint(thePath);
        
        if (animationStyle != ASOAnimationStyleExpand) {
            startIdx = item;
        }
        
        for (int16_t idx = startIdx; idx <= item; idx++) {
            UIButton *bounceButton = [self.bounceButtons objectAtIndex:idx];
            
            /* I'm not putting in any null checks or count checks, this is a quick fix and in the case of this
             * particular project, the count for the labels will always be the same as the count for the buttons
             *      RJM
             */
            UILabel *bounceLabel = [self.bounceLabels objectAtIndex:idx];
            
            currentButtonPosition = CGPointMake(bounceButton.frame.origin.x + (bounceButton.frame.size.width/2), bounceButton.frame.origin.y + (bounceButton.frame.size.height/2));
            currentLabelPosition = CGPointMake(bounceLabel.frame.origin.x + (bounceLabel.frame.size.width/2), bounceLabel.frame.origin.y + (bounceLabel.frame.size.height/2));
            
            if (idx == item) {
                // Calculate the bounce target point
                bouncePosition = [self bounceTargetPointWithStartPoint:previousButtonPosition EndPoint:currentButtonPosition];
                labelBouncePosition = [self bounceTargetPointWithStartPoint:previousLabelPosition EndPoint:currentLabelPosition];
                
                CGPathAddLineToPoint(thePath, NULL, bouncePosition.x, bouncePosition.y);
                CGPathAddLineToPoint(labelPath, NULL, labelBouncePosition.x, labelBouncePosition.y);
            }
            
            CGPathAddLineToPoint(thePath, NULL, currentButtonPosition.x, currentButtonPosition.y);
            CGPathAddLineToPoint(labelPath, NULL, currentLabelPosition.x, currentLabelPosition.y);
            
            previousButtonPosition = currentButtonPosition;
            previousLabelPosition = currentLabelPosition;
        }
        
        CAKeyframeAnimation * theAnimation;
        CAKeyframeAnimation * labelAnimation;
        
        // Create the animation object, specifying the position property as the key path.
        theAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
        theAnimation.path=thePath;
        
        labelAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        labelAnimation.path = labelPath;
        
        if (animationStyle != ASOAnimationStyleRiseConcurrently) {
            theAnimation.duration = [self.speed floatValue] * (item + 1);
            labelAnimation.duration = [self.speed floatValue] * (item + 1);
        } else {
            theAnimation.duration = [self.speed floatValue];
            labelAnimation.duration = [self.speed floatValue];
        }

        // Add the animation to the layer.
        [[self.bounceButtons objectAtIndex:item] layer].opacity = 1.0;
        [[[self.bounceButtons objectAtIndex:item] layer] addAnimation:theAnimation forKey:@"position"];
        
        [[self.bounceLabels objectAtIndex:item] layer].opacity = 1.0;
        [[[self.bounceLabels objectAtIndex:item] layer] addAnimation:labelAnimation forKey:@"positoin"];
    }
}

- (void)collapseWithAnimationStyle:(ASOAnimationStyle)animationStyle
{
    UIButton *bounceButton = [[UIButton alloc] init];
    UILabel *bounceLabel = [[UILabel alloc] init];
    self.collapsedViewDuration = [NSNumber numberWithFloat:0.0];
    int16_t lastIdx = 0;
    
    // Process and collapse all the buttons
    for (int16_t item = 0; item < [self.bounceButtons count]; item++) {
        CGMutablePathRef thePath = CGPathCreateMutable();
        CGMutablePathRef labelPath = CGPathCreateMutable();
        
        if (animationStyle != ASOAnimationStyleExpand) {
            lastIdx = item;
        }
        
        for (int16_t idx = item; idx >= lastIdx; idx--) {
            bounceButton = [self.bounceButtons objectAtIndex:idx];
            bounceLabel = [self.bounceLabels objectAtIndex:idx];
            if (idx == item) {
                CGPathMoveToPoint(thePath, NULL, bounceButton.frame.origin.x + (bounceButton.frame.size.width/2), bounceButton.frame.origin.y + (bounceButton.frame.size.height/2));
                CGPathMoveToPoint(labelPath, NULL, bounceLabel.frame.origin.x + (bounceLabel.frame.size.width/2), bounceLabel.frame.origin.y + (bounceLabel.frame.size.height/2));
            }
            else {
                CGPathAddLineToPoint(thePath, NULL, bounceButton.frame.origin.x + (bounceButton.frame.size.width/2), bounceButton.frame.origin.y + (bounceButton.frame.size.height/2));
                CGPathAddLineToPoint(labelPath, NULL, bounceLabel.frame.origin.x + (bounceLabel.frame.size.width/2), bounceLabel.frame.origin.y + (bounceLabel.frame.size.height/2));
            }
            
        }
        
        CGPathAddLineToPoint(thePath,NULL,self.startAnimationPoint.x, self.startAnimationPoint.y);
        CGPathAddLineToPoint(labelPath, NULL, self.startAnimationPoint.x, self.startAnimationPoint.y);
        
        CAKeyframeAnimation * collapsedAnimation;
        collapsedAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        collapsedAnimation.path = thePath;
        
        CAKeyframeAnimation * labelCollAnimation;
        labelCollAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        labelCollAnimation.path = labelPath;
        
        CABasicAnimation *theFadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        theFadeOutAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        theFadeOutAnimation.toValue = [NSNumber numberWithFloat:0.0];
        
        CABasicAnimation *labFadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        labFadeOutAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        labFadeOutAnimation.toValue = [NSNumber numberWithFloat:0.0];
        
        if (animationStyle != ASOAnimationStyleRiseConcurrently) {
            theFadeOutAnimation.duration = [self.speed floatValue] * (item + 1);
            labFadeOutAnimation.duration = [self.speed floatValue] * (item + 1);
        } else {
            theFadeOutAnimation.duration = [self.speed floatValue];
            labFadeOutAnimation.duration = [self.speed floatValue];
        }
        
        [[self.bounceButtons objectAtIndex:item] layer].opacity = 0.0;
        [[self.bounceLabels objectAtIndex:item] layer].opacity = 0.0;
        
        CAAnimationGroup *groupedAnimation = [CAAnimationGroup animation];
        groupedAnimation.animations = [NSArray arrayWithObjects:collapsedAnimation, theFadeOutAnimation, nil];
        
        CAAnimationGroup *labGrpdAnimation = [CAAnimationGroup animation];
        labGrpdAnimation.animations = [NSArray arrayWithObjects:labelCollAnimation, labFadeOutAnimation, nil];
        
        if (animationStyle != ASOAnimationStyleRiseConcurrently) {
            groupedAnimation.duration = [self.speed floatValue] * (item + 1);
            labGrpdAnimation.duration = [self.speed floatValue] * (item + 1);
        } else {
            groupedAnimation.duration = [self.speed floatValue];
            labGrpdAnimation.duration = [self.speed floatValue];
        }
        
        [[[self.bounceButtons objectAtIndex:item] layer] addAnimation:groupedAnimation forKey:@"collapsed-fadeout"];
        [[[self.bounceLabels objectAtIndex:item] layer] addAnimation:labGrpdAnimation forKey:@"collapsed-fadeout"];
    }
    
    self.collapsedViewDuration = [NSNumber numberWithDouble:([self.speed doubleValue] * [self.bounceButtons count])];
}

@end
