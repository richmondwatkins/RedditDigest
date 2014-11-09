//
//  KTCenterFlowLayout.m
//
//  Created by Kyle Truscott on 10/9/14.
//  Copyright (c) 2014 keighl. All rights reserved.
//

#import "KTCenterFlowLayout.h"

static const CGFloat kIDScrollResistanceFactor = 900.0f;

@interface KTCenterFlowLayout ()

@property (strong, nonatomic) UIDynamicAnimator *springAnimator;

@property (strong, nonatomic) NSMutableSet *visibleIndexPaths;
@property (assign, nonatomic) CGFloat lastDelta;
@end

@implementation KTCenterFlowLayout

- (instancetype)init {
    self = [super init];
    if ( self ) {
        self.minimumLineSpacing = 10.0f;
        self.itemSize = CGSizeMake(90, 90);
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);

        _springAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
        _visibleIndexPaths = [NSMutableSet set];
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];

    CGRect visibleRect = CGRectInset((CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size}, -100, -100);
    NSArray *itemsInVisibleRect = [super layoutAttributesForElementsInRect:visibleRect];

    NSSet *itemsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRect valueForKey:@"indexPath"]];

    // Create an array of behaviors that aren't visible using the set of visible index path
    NSArray *hiddenBehaviors = [self.springAnimator.behaviors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behavior, NSDictionary *bindings){
        BOOL currentlyVisible = [itemsInVisibleRectSet containsObject:[[[behavior items] firstObject] indexPath]] == NO;
        return currentlyVisible;
    }]];

    // Iterate over hiddenBehaviors and remove them from the dynamic animator and visible index path set
    [hiddenBehaviors enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
        [self.springAnimator removeBehavior:obj];
        [self.visibleIndexPaths removeObject:[[[obj items] lastObject] indexPath]];
    }];

    NSArray *newlyVisibleItems = [itemsInVisibleRect filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings){
        BOOL currentlyVisible = [self.visibleIndexPaths containsObject:item.indexPath] == NO;
        return currentlyVisible;
    }]];

    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];

    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger index, BOOL *stop){
        CGPoint itemCenter = item.center;
        UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:itemCenter];

        springBehavior.length = 1.0f;
        springBehavior.damping = 0.8f;
        springBehavior.frequency = 0.5f;

        if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
            CGFloat distanceFromTouch = fabsf(touchLocation.y - springBehavior.anchorPoint.y);
            CGFloat scrollResistance = distanceFromTouch / kIDScrollResistanceFactor;

            if ( self.lastDelta < 0 ) {
                itemCenter.y += MAX(self.lastDelta, self.lastDelta * scrollResistance);
            }
            else {
                itemCenter.y += MIN(self.lastDelta, self.lastDelta * scrollResistance);
            }

            item.center = itemCenter;
        }

        [self.springAnimator addBehavior:springBehavior];
        [self.visibleIndexPaths addObject:item.indexPath];
    }];
}

//- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
//{
//    return [self.springAnimator itemsInRect:rect];
//}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.springAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    UIScrollView *scrollView = self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;

    self.lastDelta = delta;

    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];

    [self.springAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *behavior, NSUInteger index, BOOL* stop){
        CGFloat distanceFromTouch = fabsf(touchLocation.y - behavior.anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / kIDScrollResistanceFactor;

        UICollectionViewLayoutAttributes *item = [behavior.items firstObject];
        CGPoint itemCenter = item.center;

        if ( delta < 0 ) {
            itemCenter.y += MAX(delta, delta * scrollResistance);
        }
        else {
            itemCenter.y += MIN(delta, delta * scrollResistance);
        }

        item.center = itemCenter;
        [self.springAnimator updateItemUsingCurrentState:item];
    }];

    return NO;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    [self.springAnimator itemsInRect:rect];

    NSMutableArray *superAttributes = [NSMutableArray arrayWithArray:[self.springAnimator itemsInRect:rect]];//[super layoutAttributesForElementsInRect:rect]];

    NSMutableDictionary *rowCollections = [NSMutableDictionary new];

    // Collect attributes by their midY coordinate.. i.e. rows!
    for (UICollectionViewLayoutAttributes *itemAttributes in superAttributes)
    {
        NSNumber *yCenter = @(CGRectGetMidY(itemAttributes.frame));

        if (!rowCollections[yCenter]) {
          rowCollections[yCenter] = [NSMutableArray new];
        }

        [rowCollections[yCenter] addObject:itemAttributes];
    }

  // Adjust the items in each row
    [rowCollections enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         NSArray *itemAttributesCollection = obj;
         NSInteger itemsInRow = [itemAttributesCollection count];

        // x-x-x-x ... sum up the interim space
        CGFloat aggregateInteritemSpacing = self.minimumInteritemSpacing * (itemsInRow -1);

        // Sum the width of all elements in the row
        CGFloat aggregateItemWidths = 0.f;
        for (UICollectionViewLayoutAttributes *itemAttributes in itemAttributesCollection)
          aggregateItemWidths += CGRectGetWidth(itemAttributes.frame);

        // Build an alignment rect
        // |==|--------|==|
        CGFloat alignmentWidth = aggregateItemWidths + aggregateInteritemSpacing;
        CGFloat alignmentXOffset = (CGRectGetWidth(self.collectionView.bounds) - alignmentWidth) / 2.f;

        // Adjust each item's position to be centered
        CGRect previousFrame = CGRectZero;
        for (UICollectionViewLayoutAttributes *itemAttributes in itemAttributesCollection)
        {
          CGRect itemFrame = itemAttributes.frame;

          if (CGRectEqualToRect(previousFrame, CGRectZero))
            itemFrame.origin.x = alignmentXOffset;
          else
            itemFrame.origin.x = CGRectGetMaxX(previousFrame) + self.minimumInteritemSpacing;

          itemAttributes.frame = itemFrame;
          previousFrame = itemFrame;
        }
     }];

    //return [self.springAnimator itemsInRect:superAttributes];

    return superAttributes;
}


@end
