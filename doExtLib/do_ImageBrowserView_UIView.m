//
//  do_ImageBrowserView_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_ImageBrowserView_UIView.h"

#import "doInvokeResult.h"
#import "doUIModuleHelper.h"
#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doJsonHelper.h"
#import "DOVImageBrowser.h"

@implementation do_ImageBrowserView_UIView
{
    DOVImageBrowser *_browser;
    NSInteger _index;
    NSArray *_parms;
    NSArray *_imgs;
}
#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
    
    _browser = [DOVImageBrowser new];
    _browser.browserModel = _model;
    _index = 0;
    _parms = [NSArray array];
    _imgs = [NSArray array];
}
//销毁所有的全局对象
- (void) OnDispose
{
    //自定义的全局属性,view-model(UIModel)类销毁时会递归调用<子view-model(UIModel)>的该方法，将上层的引用切断。所以如果self类有非原生扩展，需主动调用view-model(UIModel)的该方法。(App || Page)-->强引用-->view-model(UIModel)-->强引用-->view
}
//实现布局
- (void) OnRedraw
{
    //实现布局相关的修改,如果添加了非原生的view需要主动调用该view的OnRedraw，递归完成布局。view(OnRedraw)<显示布局>-->调用-->view-model(UIModel)<OnRedraw>
    
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:_model];

    CGRect r = self.frame;
    r.size.width = [self getCalcValue:r.size.width];
    self.frame = r;
    _browser.frame = self.bounds;
}
- (int) getCalcValue:(double)value
{
    if (value == 0) {
        return value;
    }
    if (value < 1 && value > 0) {
        return 1;
    }
    
    double temp = (int) value + 0.44445;
    
    if (value < temp){
        if (value==0) {
            value = 1;
        }
        return (int) value;
    }
    
    return (int) value + 1;
    
}
#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */
- (void)change_index:(NSString *)newValue
{
    //自己的代码实现
    _index = [newValue integerValue];
    if (_index<0 || _index==NSNotFound) {
        _index = 0;
    }
    if (_imgs.count==0 && _parms.count==0) {
        return;
    }
    _browser.currentImageIndex = _index;
    [self resetBrowser];
    
    [_browser fireEvent:@"indexChanged"];
}

#pragma mark -
#pragma mark - 同步异步方法的实现
//同步
- (void)bindItems:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    _parms = parms;
    //_invokeResult设置返回值
    _imgs = [doJsonHelper GetOneArray:[parms objectAtIndex:0] :@"data"];
    if (_index>(_imgs.count-1)) {
        _index = 0;
    }
    [self resetBrowser];
}

- (void)resetBrowser
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_browser show:_imgs :_index :_parms];
        [_browser clearContents:_browser.subviews];
        [_browser removeFromSuperview];
        [self addSubview:_browser];
        [_browser createContents];
    });
}

#pragma mark - doIUIModuleView协议方法（必须）<大部分情况不需修改>
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    //属性改变时,返回NO，将不会执行Changed方法
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    //_model的属性进行修改，同时调用self的对应的属性方法，修改视图
    [doUIModuleHelper HandleViewProperChanged: self :_model : _changedValues ];
}
- (BOOL) InvokeSyncMethod: (NSString *) _methodName : (NSDictionary *)_dicParas :(id<doIScriptEngine>)_scriptEngine : (doInvokeResult *) _invokeResult
{
    //同步消息
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dicParas :_scriptEngine :_invokeResult];
}
- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (NSDictionary *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    //异步消息
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
- (doUIModule *) GetModel
{
    //获取model对象
    return _model;
}

@end
