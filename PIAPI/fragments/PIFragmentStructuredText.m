//
//  PIFragmentStructuredText.m
//  PIAPI
//
//  Created by Étienne VALLETTE d'OSIA on 09/12/2013.
//  Copyright (c) 2013 Zengularity. All rights reserved.
//

#import "PIFragmentStructuredText.h"

#import "PIFragmentImage.h"
#import "PIFragmentEmbed.h"

@interface PIFragmentStructuredText () {
    NSMutableArray *_blocks;
}
@end

@implementation PIFragmentStructuredText

+ (id <PIFragmentBlock>)parseBlock:(id)jsonObject
{
    id <PIFragmentBlock> block = nil;
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSString *type = jsonObject[@"type"];
        id <PIFragmentBlock> (^selectedCase)() = @{
            @"paragraph" : ^{
                return [PIFragmentBlockParagraph BlockWithJson:jsonObject];
            },
            @"preformatted" : ^{
                return [PIFragmentBlockPreformatted BlockWithJson:jsonObject];
            },
            @"heading1" : ^{
                return [PIFragmentBlockHeading BlockWithJson:jsonObject heading:@1];
            },
            @"heading2" : ^{
                return [PIFragmentBlockHeading BlockWithJson:jsonObject heading:@2];
            },
            @"heading3" : ^{
                return [PIFragmentBlockHeading BlockWithJson:jsonObject heading:@3];
            },
            @"heading4" : ^{
                return [PIFragmentBlockHeading BlockWithJson:jsonObject heading:@4];
            },
            @"list-item" : ^{
                return [PIFragmentBlockListItem BlockWithJson:jsonObject];
            },
            @"o-list-item" : ^{
                return [PIFragmentBlockOrderedListItem BlockWithJson:jsonObject];
            },
            @"image" : ^{
                PIFragmentImageView *view = [PIFragmentImageView ViewWithJson:jsonObject];
                return [[PIFragmentBlockImage alloc] init:view];
            },
            @"embed" : ^{
                PIFragmentEmbed *embed = [[PIFragmentEmbed alloc] initWithJson:jsonObject];
                return [[PIFragmentBlockEmbed alloc] init:embed];
            },
        }[type];
        if (selectedCase != nil) {
            block = selectedCase();
        }
        else {
            NSLog(@"Unsupported block type: %@", type);
        }
    }
    return block;
}

+ (PIFragmentStructuredText *)StructuredTextWithJson:(id)jsonObject
{
    PIFragmentStructuredText *structuredText = [[PIFragmentStructuredText alloc] init];
    
    structuredText->_blocks = [[NSMutableArray alloc] init];
    NSDictionary *values = jsonObject[@"value"];
    for (NSDictionary *field in values) {
        id <PIFragmentBlock> block = [self parseBlock:field];
        if (block != nil) {
            [structuredText->_blocks addObject:block];
        }
    }
    
    return structuredText;
}

- (NSArray *)blocks
{
    return _blocks;
}

- (PIFragmentBlockHeading *)firstTitleObject
{
    PIFragmentBlockHeading *res = nil;
    for (id <PIFragmentBlock> block in _blocks) {
        if ([block isKindOfClass:[PIFragmentBlockHeading class]]) {
            PIFragmentBlockHeading *heading = (PIFragmentBlockHeading *)block;
            if (res == nil || [res heading] < [heading heading]) {
                res = heading;
            }
        }
    }
    return res;
}

- (NSAttributedString *)firstTitleFormatted
{
    PIFragmentBlockHeading *heading = [self firstTitleObject];
    if (heading) {
        return [heading formattedText];
    }
    return nil;
}

- (NSString *)firstTitle
{
    PIFragmentBlockHeading *heading = [self firstTitleObject];
    if (heading) {
        return [heading text];
    }
    return nil;
}

- (PIFragmentBlockParagraph *)firstParagraphObject
{
    PIFragmentBlockParagraph *res = nil;
    for (id <PIFragmentBlock> block in _blocks) {
        if ([block isKindOfClass:[PIFragmentBlockParagraph class]]) {
            return (PIFragmentBlockParagraph *)block;
        }
    }
    return res;
}

- (NSAttributedString *)firstParagraphFormatted
{
    PIFragmentBlockParagraph *paragraph = [self firstParagraphObject];
    if (paragraph) {
        return [paragraph formattedText];
    }
    return nil;
}

- (NSString *)firstParagraph
{
    PIFragmentBlockParagraph *paragraph = [self firstParagraphObject];
    if (paragraph) {
        return [paragraph text];
    }
    return nil;
}

@end
