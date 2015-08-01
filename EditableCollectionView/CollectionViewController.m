//
//  CollectionViewController.m
//  EditableCollectionView
//
//  Created by NSSimpleApps on 08.06.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "CollectionViewController.h"
#import "DraggableFlowLayout.h"

@interface CollectionViewController () <DraggableFlowLayoutDelegate, DraggableFlowLayoutDataSource>

@property (strong, nonatomic) NSMutableArray *array;

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.array = [@[@"1", @"2", @"3", @"4", @"5"] mutableCopy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[cell viewWithTag:101];
    label.text = self.array[indexPath.row];
    
    return cell;
}

- (BOOL)canDragItemAtIndexPath:(NSIndexPath*)indexPath {
    
    return YES;
}

- (void)draggingDidEndFromIndexPath:(NSIndexPath*)oldIndexPath toIndexPath:(NSIndexPath*)newIndexPath {
    
    id obj = [self.array objectAtIndex:oldIndexPath.row];
    
    [self.array removeObjectAtIndex:oldIndexPath.row];
    [self.array insertObject:obj atIndex:newIndexPath.row];
}

@end
