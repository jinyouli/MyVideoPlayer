//
//  MainViewController.m
//  VKPlayerDemo
//
//  Created by jinyou on 2017/11/23.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "MainViewController.h"
#import "ViewController.h"

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) NSMutableArray *arrayData;
@property (nonatomic,copy) NSString *docsDir;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"视频播放";
    
    self.arrayData = [NSMutableArray array];
    
    self.tableview = [[UITableView alloc] init];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableview];
    
    [self initData];
}

- (void)initData
{
    self.docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:self.docsDir];
    
    NSString *fileName;
    
    while (fileName = [dirEnum nextObject]) {
        
        NSLog(@"file == %@",fileName);
        NSLog(@"filePath == %@",[self.docsDir stringByAppendingPathComponent:fileName]);
        
        [self.arrayData addObject:fileName];
    }
    
    [self.tableview reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.arrayData objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
    if (self.arrayData.count > 0) {
        NSString *filePath = [self.docsDir stringByAppendingPathComponent:[self.arrayData objectAtIndex:indexPath.row]];
        
        ViewController *view = [[ViewController alloc] init];
        view.filePath = filePath;
        view.fileName = [self.arrayData objectAtIndex:indexPath.row];
        [self presentViewController:view animated:YES completion:nil];
    }
    
}

- (void)viewDidLayoutSubviews
{
    self.tableview.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
