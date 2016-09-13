//
//  ViewController.m
//  Demo
//
//  Created by 涂飞 on 16/9/14.
//  Copyright © 2016年 Tu. All rights reserved.
//

#import "TableViewController.h"
#import "TTPerfMonitor/TTPerfMonitor.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[TTPerfMonitor shareInstance] show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Delegate

#pragma mark - DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 100;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    float i = rand() % 255 / 255.0;
    float j = rand() % 255 / 255.0;
    float k = rand() % 255 / 255.0;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.contentView.backgroundColor = [UIColor colorWithRed:i green:j blue:k alpha:1.0];
    cell.contentView.layer.cornerRadius = 3.0;
    cell.contentView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    cell.contentView.layer.shadowOpacity = 0.5;
    
    return cell;
}


@end
