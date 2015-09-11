//
//  testViewController.m
//  OpenglVideo
//
//  Created by Lightning on 15/9/10.
//  Copyright (c) 2015年 Lightning. All rights reserved.
//

#import "testViewController.h"

@interface testViewController ()

@end

@implementation testViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [@(indexPath.row) stringValue];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blueColor];
    UILabel *lab = [[UILabel alloc] init];
    [view addSubview:lab];
    lab.text = @"I'm section header";
    [lab sizeToFit];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

@end
