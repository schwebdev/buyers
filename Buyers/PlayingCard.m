//
//  PlayingCard.m
//  LXRCVFL Example using Storyboard
//
//  Created by Stan Chang Khin Boon on 3/10/12.
//  Copyright (c) 2012 d--buzz. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

- (NSString *)imageName {
    switch (self.suit) {
        case PlayingCardSuitSpade:
            return [NSString stringWithFormat:@"s%ld.png", (long)self.rank];
        case PlayingCardSuitHeart:
            return [NSString stringWithFormat:@"h%ld.png", (long)self.rank];
        case PlayingCardSuitClub:
            return [NSString stringWithFormat:@"c%ld.png", (long)self.rank];
        case PlayingCardSuitDiamond:
            return [NSString stringWithFormat:@"d%ld.png", (long)self.rank];
    }
}

@end
