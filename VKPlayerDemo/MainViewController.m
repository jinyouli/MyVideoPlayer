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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initData];
}

- (void)initData
{
    [self.arrayData removeAllObjects];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *filePath = [self.docsDir stringByAppendingPathComponent:[self.arrayData objectAtIndex:indexPath.row]];
    NSString *fileName = [self.arrayData objectAtIndex:indexPath.row];
    
    [self deleteFile:filePath fileName:fileName indexPath:indexPath];
} /** * 修改Delete按钮文字为“删除” */
    
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath { return @"删除"; }

- (void)deleteFile:(NSString *)filePath fileName:(NSString *)fileName indexPath:(NSIndexPath *)indexPath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    BOOL bRet = [fileMgr fileExistsAtPath:filePath];
    if (bRet) {
        NSError *err;
        [fileMgr removeItemAtPath:filePath error:&err];

        NSString *msg;
        if (err) {
            msg = [NSString stringWithFormat:@"%@",err];
        }else{
            msg = @"删除成功";
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:fileName];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
        
        // 删除模型
        [self.arrayData removeObjectAtIndex:indexPath.row];
        // 刷新
        [self.tableview deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
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
