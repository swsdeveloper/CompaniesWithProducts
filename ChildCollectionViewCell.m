//
//  ChildCollectionViewCell.m
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 2/16/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import "ChildCollectionViewCell.h"

@implementation ChildCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"ChildCollectionViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        if (![arrayOfViews[0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = arrayOfViews[0];
    }
    return self;
}

@end
