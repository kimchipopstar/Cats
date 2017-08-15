//
//  ViewController.m
//  temp
//
//  Created by Jaewon Kim on 2017-08-14.
//  Copyright © 2017 Jaewon Kim. All rights reserved.
//

#import "ViewController.h"
#import "Photo.h"
#import "photoCell.h"

@interface ViewController () <UICollectionViewDelegate,UICollectionViewDataSource>

@property NSMutableArray *photoMutArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photoMutArray = [NSMutableArray new];
    NSURL *url = [NSURL URLWithString:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=e8d9e7e7d3f9e95e21133c346e36713e&tags=cat"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"GET";
    
    
    NSLog(@"here");
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest
                                                   completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                       
                                                       
                                                       if (error) {
                                                           NSLog(@"Error getting data");
                                                       } else {
                                                           
                                                           NSLog(@"no error");
                                                           NSError *jsonError = nil;
                                                           NSDictionary *catPics = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                           
                                                           if (jsonError)
                                                           {
                                                               NSLog(@"jsonError:%@",jsonError.localizedDescription);
                                                           } else {
                   
                                                               NSDictionary *photosDict = catPics[@"photos"];
                                                               
                                                               NSArray *photoArray = photosDict[@"photo"];

                                                               for (NSDictionary *photoDict in photoArray) {
                                                                   Photo *photo = [Photo new];
                                                                   photo.farm = photoDict[@"farm"];
                                                                   photo.server = photoDict[@"server"];
                                                                   photo.secret = photoDict[@"secret"];
                                                                   photo.iD = photoDict[@"id"];
                                                                   photo.isfamily = photoDict[@"isfamily"];
                                                                   photo.isfriend = photoDict[@"isfriend"];
                                                                   photo.ispublic = photoDict[@"ispublic"];
                                                                   photo.owner = photoDict[@"owner"];
                                                                   photo.title = photoDict[@"title"];
                                                                   photo.url = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg",photo.farm,photo.server,photo.iD,photo.secret];
                                                                   NSLog(@"%@",photo.url);
                                                                   
                                                                   [self.photoMutArray addObject:photo];
                                                               }
                                                               
                                                           }

                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               [self.collectionView reloadData];
                                                           });
                                                       }
                                                       
                                                   }];
    
    [dataTask resume];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoMutArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    photoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photocell" forIndexPath:indexPath];
    
    Photo * thisPhoto = [self.photoMutArray objectAtIndex:indexPath.row];
    NSURL *imageURL = [NSURL URLWithString:thisPhoto.url];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
    cell.imageView.image = [UIImage imageWithData:imageData];
    cell.titleLabel.text = thisPhoto.title;
    
    return cell;
}


@end
