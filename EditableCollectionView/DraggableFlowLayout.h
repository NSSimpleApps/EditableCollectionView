//
//  DraggableFlowLayout.h
//  EditableCollectionView
//
//  Created by NSSimpleApps on 07.06.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DraggableFlowLayoutDelegate

- (BOOL)canDragItemAtIndexPath:(NSIndexPath*)indexPath;

@end

@protocol DraggableFlowLayoutDataSource

- (void)draggingDidEndFromIndexPath:(NSIndexPath*)oldIndexPath toIndexPath:(NSIndexPath*)newIndexPath;

@end


@interface DraggableFlowLayout : UICollectionViewFlowLayout

@end
