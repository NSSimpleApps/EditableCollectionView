//
//  DraggableFlowLayout.m
//  EditableCollectionView
//
//  Created by NSSimpleApps on 07.06.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "DraggableFlowLayout.h"

static NSString * const kCollectionView = @"collectionView";


@implementation UIView (SnapshotView)

- (UIView *)snapshotView {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [[UIImageView alloc] initWithImage:image];
}

@end


@interface DraggableFlowLayout ()

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;

@end

@implementation DraggableFlowLayout

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self addObserver:self
               forKeyPath:kCollectionView
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self addObserver:self
               forKeyPath:kCollectionView
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    }
    return self;
}

- (void)dealloc {
    
    [self removeObserver:self forKeyPath:kCollectionView];
    
    [self.longPressRecognizer.view removeGestureRecognizer:self.longPressRecognizer];
}

- (id<DraggableFlowLayoutDelegate>)delegate {
    
    if ([self.collectionView.delegate conformsToProtocol:@protocol(DraggableFlowLayoutDelegate)]) {
        
        return (id<DraggableFlowLayoutDelegate>)self.collectionView.delegate;
    }
    return nil;
}

- (id<DraggableFlowLayoutDataSource>)dataSource {
    
    if ([self.collectionView.dataSource conformsToProtocol:@protocol(DraggableFlowLayoutDataSource)]) {
        
        return (id<DraggableFlowLayoutDataSource>)self.collectionView.dataSource;
    }
    return nil;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:kCollectionView]) {
        
        self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleLongPressRecognizer:)];
        
        for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
            
            if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                
                [gestureRecognizer requireGestureRecognizerToFail:self.longPressRecognizer];
            }
        }
        [self.collectionView addGestureRecognizer:self.longPressRecognizer];
    }
}

- (void)handleLongPressRecognizer:(UILongPressGestureRecognizer*)sender {
    
    static UIView *snapshotView = nil;
    static NSIndexPath *initialIndexPath = nil;
    static NSIndexPath *currentIndexPath = nil;
    
    CGPoint location = [sender locationInView:sender.view];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    switch (sender.state) {
            
    case UIGestureRecognizerStateBegan: {
            
        if (!indexPath) break;
        
        currentIndexPath = indexPath;
        initialIndexPath = indexPath;
        
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
                
        snapshotView = [cell snapshotView];
                
        __block CGPoint center = cell.center;
        snapshotView.center = center;
        snapshotView.alpha = 0.0;
        [self.collectionView addSubview:snapshotView];
        [UIView animateWithDuration:0.2 animations:^{
                    
            center = location;
            snapshotView.center = center;
            snapshotView.transform = CGAffineTransformMakeScale(1.1, 1.1);
            snapshotView.alpha = 0.8;
            cell.alpha = 0.0;
        } completion:^(BOOL finished) {
                    
            cell.hidden = YES;
        }];
        break;
    }
    case UIGestureRecognizerStateChanged: {
        
        CGPoint center = snapshotView.center;
        center = location;
        snapshotView.center = center;
        
        if (indexPath && ![indexPath isEqual:currentIndexPath]) {
            
            if ([self.delegate canDragItemAtIndexPath:currentIndexPath]
                && [self.delegate canDragItemAtIndexPath:indexPath]) {
                
                [self.collectionView moveItemAtIndexPath:currentIndexPath toIndexPath:indexPath];
                currentIndexPath = indexPath;
            }
        }
        break;
    }
    case UIGestureRecognizerStateEnded: {
            
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:currentIndexPath];
        cell.hidden = NO;
        cell.alpha = 0.0;
        
        [self.dataSource draggingDidEndFromIndexPath:initialIndexPath toIndexPath:currentIndexPath];
        
        [UIView animateWithDuration:0.3 animations:^{
                
            snapshotView.center = cell.center;
            snapshotView.transform = CGAffineTransformIdentity;
            snapshotView.alpha = 0.0;
            cell.alpha = 1.0;
                
        } completion:^(BOOL finished) {
                
            currentIndexPath = nil;
            initialIndexPath = nil;
            [snapshotView removeFromSuperview];
            snapshotView = nil;
        }];
        break;
    }
    default:
    break;
    }
}

@end
