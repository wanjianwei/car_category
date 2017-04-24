// Copyright 2015 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import "CameraExampleViewController.h"
#include <sys/time.h>
#include "tensorflow_utils.h"
#include "MBProgressHUD.h"
#include "ResultTableViewController.h"

// If you have your own model, modify this to the file name, and make sure
// you've added the file to your app resources too.

/*
static NSString* model_file_name = @"tensorflow_inception_graph";
static NSString* model_file_type = @"pb";
// This controls whether we'll be loading a plain GraphDef proto, or a
// file created by the convert_graphdef_memmapped_format utility that wraps a
// GraphDef and parameter file that can be mapped into memory from file to
// reduce overall memory usage.
const bool model_uses_memory_mapping = false;
// If you have your own model, point this to the labels file.
static NSString* labels_file_name = @"imagenet_comp_graph_label_strings";
static NSString* labels_file_type = @"txt";
// These dimensions need to match those the model was trained with.

const int wanted_input_width = 224;
const int wanted_input_height = 224;
const int wanted_input_channels = 3;
const float input_mean = 117.0f;
const float input_std = 1.0f;
const std::string input_layer_name = "input";
const std::string output_layer_name = "softmax1";
*/


static NSString* model_file_name = @"output_graph_rear_1";
static NSString* model_file_type = @"pb";
const bool model_uses_memory_mapping = false;
static NSString* labels_file_name = @"output_labels";
static NSString* labels_file_type = @"txt";

const int wanted_input_width = 299;
const int wanted_input_height = 299;
const int wanted_input_channels = 3;
const float input_mean = 128.0f;
const float input_std = 128.0f;
const std::string input_layer_name = "Mul";
const std::string output_layer_name = "final_result";



@interface CameraExampleViewController (InternalMethods)
- (void)setupAVCapture;
- (void)teardownAVCapture;
@end

@implementation CameraExampleViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //定义导航栏
    self.title = @"车型识别";
    //添加previewView
    previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-60-64)];
    [self.view addSubview:previewView];
    [previewView release];
    
    //添加手势识别
    UIPinchGestureRecognizer * pinchRecgnizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinchRecgnizer.delegate = self;
    [previewView addGestureRecognizer:pinchRecgnizer];
    
    self.beginGestureScale = 1.0f;
    self.effectiveScale = 1.0f;
    //添加拍照识别的按钮
    photoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(previewView.frame), [UIScreen mainScreen].bounds.size.width, 60)];
    [photoBtn addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    photoBtn.backgroundColor = [UIColor redColor];
    [photoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [photoBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    photoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [photoBtn setTitle:@"车型拍照" forState:UIControlStateNormal];
    [self.view addSubview:photoBtn];
    [photoBtn release];
    
    tensorflow::Status load_status;
    if (model_uses_memory_mapping) {
        load_status = LoadMemoryMappedModel(
                                            model_file_name, model_file_type, &tf_session, &tf_memmapped_env);
    } else {
        load_status = LoadModel(model_file_name, model_file_type, &tf_session);
    }
    if (!load_status.ok()) {
        [self showHUDWithNSString:@"无法加载模型"];
        [self.navigationController popViewControllerAnimated:YES];
        LOG(FATAL) << "Couldn't load model: " << load_status;
    }
    
    tensorflow::Status labels_status =
    LoadLabels(labels_file_name, labels_file_type, &labels);
    if (!labels_status.ok()) {
        [self showHUDWithNSString:@"无法加载分类标签"];
        [self.navigationController popViewControllerAnimated:YES];
        LOG(FATAL) << "Couldn't load labels: " << labels_status;
    }
    [self setupAVCapture];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    [self teardownAVCapture];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)setupAVCapture {
    
    NSError *error = nil;
    session = [AVCaptureSession new];
    
    //是否使用前置摄像头
   // isUsingFrontFacingCamera = NO;
    
    //设置视频质量
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [session setSessionPreset:AVCaptureSessionPreset640x480];
    else
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    //设置输入设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    assert(error == nil);
    if ([session canAddInput:deviceInput])
        [session addInput:deviceInput];
    //图片输出
    stillImageOutput = [AVCaptureStillImageOutput new];
    //设置图片输出格式
    NSDictionary *rgbOutputSettings = [NSDictionary
                                       dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA]
                                       forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [stillImageOutput setOutputSettings:rgbOutputSettings];
    //添加输出设备
    if ([session canAddOutput:stillImageOutput])
        [session addOutput:stillImageOutput];
    //建立连接,conn没有alloc，new。是一个自动释放的类型变量
    conn =  [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //设置图像输出显示图层
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = [previewView layer];
    [rootLayer setMasksToBounds:YES];
    
    //设置previewlayer的尺寸
    [previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:previewLayer];
    
    //添加bounding box类似的方框
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(20, 30, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.width-40) cornerRadius:0];
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor greenColor].CGColor;
    shapeLayer.lineWidth = 2.0f;
    [rootLayer addSublayer:shapeLayer];
    //起初要添加noticeLayer
    [self showNoticeLayerWithBool:YES];
    
    //开启session
    [session startRunning];
    [session release];
    
    if (error) {
        [self showHUDWithNSString:error.localizedDescription];
    }
}

- (void)teardownAVCapture {
    /*
    if (photoPixelBuffer != nil) {
        CVBufferRelease(photoPixelBuffer);
    }
     */
  [stillImageOutput release];
  [previewLayer removeFromSuperlayer];
  [previewLayer release];
}


- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:
    (UIDeviceOrientation)deviceOrientation {
  AVCaptureVideoOrientation result =
      (AVCaptureVideoOrientation)(deviceOrientation);
  if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
    result = AVCaptureVideoOrientationLandscapeRight;
  else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
    result = AVCaptureVideoOrientationLandscapeLeft;
  return result;
}

//展示显示错误提示hud
-(void)showHUDWithNSString:(NSString * )str{
    MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:previewView animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.label.text = str;
    HUD.margin = 10;
    HUD.offset =CGPointMake(0, [UIScreen mainScreen].bounds.size.height/2.0-60);
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hideAnimated:YES afterDelay:1.5];
}

//拍照
- (void)takePicture:(id)sender{
  if ([session isRunning]) {
      //车型拍照,拍摄提示去除
      [self showNoticeLayerWithBool:NO];
      //获取图片
      UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
      AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
      [conn setVideoOrientation:avcaptureOrientation];
      //设置焦距
      [conn setVideoScaleAndCropFactor:1];
      [stillImageOutput captureStillImageAsynchronouslyFromConnection:conn completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
          //获取拍摄的图片
          photoPixelBuffer = CMSampleBufferGetImageBuffer(imageDataSampleBuffer);
          //retain，防止photoPixelBuffer变成null；
          CVBufferRetain(photoPixelBuffer);
         
          [session stopRunning];
          [sender setTitle:@"车型识别" forState:UIControlStateNormal];
          //背景颜色变成绿色
          [sender setBackgroundColor:[UIColor greenColor]];
          //在导航栏上设置重新拍照选项
          UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"重拍" style:UIBarButtonItemStyleDone target:self action:@selector(cancelPicture)];
          self.navigationItem.rightBarButtonItem = rightBtn;
          //MRC下释放,其实不释放也是可以的
          [rightBtn release];
      }];
  } else {
      //车型识别
      [self runCNNOnFrame:photoPixelBuffer];
  }
}

//重新拍照
-(void)cancelPicture{
    [photoBtn setTitle:@"车型拍照" forState:UIControlStateNormal];
    [photoBtn setBackgroundColor:[UIColor redColor]];
    
    //拍摄提示出现
    [self showNoticeLayerWithBool:YES];
    
    self.navigationItem.rightBarButtonItem = nil;
    [session startRunning];
    
}


//reviewLayer上添加noticeLayer
-(void)showNoticeLayerWithBool:(BOOL)isShow{
    if(isShow){
        if (noticeLayer == nil) {
            //添加拍照提示栏
            noticeLayer = [[CATextLayer alloc] init];
            noticeLayer.backgroundColor = [UIColor clearColor].CGColor;
            noticeLayer.fontSize = 19.0;
            noticeLayer.alignmentMode = kCAAlignmentCenter;
            noticeLayer.foregroundColor = [UIColor grayColor].CGColor;
            [noticeLayer setFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.width-40+40+30, [UIScreen mainScreen].bounds.size.width-40, 50)];
            noticeLayer.string = @"以汽车尾部为主视角可提高\n识别准确度";
            [[previewView layer] addSublayer:noticeLayer];
        }
    }else{
        if (noticeLayer != nil) {
            [noticeLayer removeFromSuperlayer];
            [noticeLayer release];
            noticeLayer = nil;
        }
    }
}


#pragma mark 运行模型

- (void)runCNNOnFrame:(CVPixelBufferRef)pixelBuffer {
    
    MBProgressHUD * activity_hud = [MBProgressHUD showHUDAddedTo:previewView animated:YES];
    activity_hud.mode = MBProgressHUDModeIndeterminate;
    activity_hud.removeFromSuperViewOnHide = YES;
    activity_hud.label.text = @"识别中";
    
    //按钮颜色变成灰色
    photoBtn.backgroundColor = [UIColor grayColor];
    
    assert(pixelBuffer != NULL);
    
    OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    int doReverseChannels;
    if (kCVPixelFormatType_32ARGB == sourcePixelFormat) {
        doReverseChannels = 1;
    } else if (kCVPixelFormatType_32BGRA == sourcePixelFormat) {
        doReverseChannels = 0;
    } else {
        //回复识别状态
        [photoBtn setBackgroundColor:[UIColor greenColor]];
        activity_hud.hidden = YES;
        assert(false);  // Unknown source format
    }

    const int sourceRowBytes = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    const int image_width = (int)CVPixelBufferGetWidth(pixelBuffer);
    const int fullHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    unsigned char *sourceBaseAddr =
        (unsigned char *)(CVPixelBufferGetBaseAddress(pixelBuffer));
    int image_height;
    unsigned char *sourceStartAddr;
    if (fullHeight <= image_width) {
        image_height = fullHeight;
        sourceStartAddr = sourceBaseAddr;
    } else {
        image_height = image_width;
        const int marginY = ((fullHeight - image_width) / 2);
        sourceStartAddr = (sourceBaseAddr + (marginY * sourceRowBytes));
    }
    const int image_channels = 4;

    assert(image_channels >= wanted_input_channels);
    tensorflow::Tensor image_tensor(
                                    tensorflow::DT_FLOAT,
                                    tensorflow::TensorShape(
                                                    {1, wanted_input_height, wanted_input_width, wanted_input_channels}));
    auto image_tensor_mapped = image_tensor.tensor<float, 4>();
    tensorflow::uint8 *in = sourceStartAddr;
    float *out = image_tensor_mapped.data();
    for (int y = 0; y < wanted_input_height; ++y) {
        float *out_row = out + (y * wanted_input_width * wanted_input_channels);
        for (int x = 0; x < wanted_input_width; ++x) {
            const int in_x = (y * image_width) / wanted_input_width;
            const int in_y = (x * image_height) / wanted_input_height;
            tensorflow::uint8 *in_pixel =
            in + (in_y * image_width * image_channels) + (in_x * image_channels);
            float *out_pixel = out_row + (x * wanted_input_channels);
            for (int c = 0; c < wanted_input_channels; ++c) {
                out_pixel[c] = (in_pixel[c] - input_mean) / input_std;
            }
        }
    }

    if (tf_session.get()) {
        std::vector<tensorflow::Tensor> outputs;
        tensorflow::Status run_status = tf_session->Run({{input_layer_name, image_tensor}}, {output_layer_name}, {}, &outputs);
        
        //恢复识别时状态
        [photoBtn setBackgroundColor:[UIColor greenColor]];
        activity_hud.hidden = YES;
        
        if (!run_status.ok()) {
            LOG(ERROR) << "Running model failed:" << run_status;
            //在这里添加提示
            [self showHUDWithNSString:@"运行模型失败"];
        
        } else {
            tensorflow::Tensor *output = &outputs[0];
            auto predictions = output->flat<float>();

            NSMutableDictionary *newValues = [NSMutableDictionary dictionary];
            for (int index = 0; index < predictions.size(); index += 1) {
                const float predictionValue = predictions(index);
                if (predictionValue > 0.05f) {
                    std::string label = labels[index % predictions.size()];
                    NSString *labelObject = [NSString stringWithCString:label.c_str()];
                    NSNumber *valueObject = [NSNumber numberWithFloat:predictionValue];
                    [newValues setObject:valueObject forKey:labelObject];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                //NSLog(@"dic = %@",newValues);
                //如果newValues为空，则弹出错误提示，否则跳转
                if (newValues.count == 0) {
                    [self showHUDWithNSString:@"车型识别失败"];
                }else{
                    ResultTableViewController * resultView = [[ResultTableViewController alloc] init];
                    resultView.resultDic = [newValues copy];
                    [self.navigationController pushViewController:resultView animated:YES];
                }
                //重新恢复拍照状态
                [self cancelPicture];
            });
        }
      //运行完成后释放图像数据
     // CVBufferRelease(pixelBuffer);
    }
}



/*
- (BOOL)prefersStatusBarHidden {
  return YES;
}
*/

#pragma mark --相机对焦
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:previewView];
        CGPoint convertedLocation = [previewLayer convertPoint:location fromLayer:previewLayer.superlayer];
        if ( ! [previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
        CGFloat maxScaleAndCropFactor = [conn videoMaxScaleAndCropFactor];
        
        if (self.effectiveScale > maxScaleAndCropFactor)
            self.effectiveScale = maxScaleAndCropFactor;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
        
    }
    
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

#pragma mark -设置预测结果展示

/*

- (void)setPredictionValues:(NSDictionary *)newValues {
    
    NSLog(@"dic = %@",newValues);
    
  const float decayValue = 0.75f;
  const float updateValue = 0.25f;
  const float minimumThreshold = 0.01f;

  NSMutableDictionary *decayedPredictionValues =
      [[NSMutableDictionary alloc] init];
  for (NSString *label in oldPredictionValues) {
    NSNumber *oldPredictionValueObject =
        [oldPredictionValues objectForKey:label];
    const float oldPredictionValue = [oldPredictionValueObject floatValue];
    const float decayedPredictionValue = (oldPredictionValue * decayValue);
    if (decayedPredictionValue > minimumThreshold) {
      NSNumber *decayedPredictionValueObject =
          [NSNumber numberWithFloat:decayedPredictionValue];
      [decayedPredictionValues setObject:decayedPredictionValueObject
                                  forKey:label];
    }
  }
  [oldPredictionValues release];
  oldPredictionValues = decayedPredictionValues;

  for (NSString *label in newValues) {
    NSNumber *newPredictionValueObject = [newValues objectForKey:label];
    NSNumber *oldPredictionValueObject =
        [oldPredictionValues objectForKey:label];
    if (!oldPredictionValueObject) {
      oldPredictionValueObject = [NSNumber numberWithFloat:0.0f];
    }
    const float newPredictionValue = [newPredictionValueObject floatValue];
    const float oldPredictionValue = [oldPredictionValueObject floatValue];
    const float updatedPredictionValue =
        (oldPredictionValue + (newPredictionValue * updateValue));
    NSNumber *updatedPredictionValueObject =
        [NSNumber numberWithFloat:updatedPredictionValue];
    [oldPredictionValues setObject:updatedPredictionValueObject forKey:label];
  }
  NSArray *candidateLabels = [NSMutableArray array];
  for (NSString *label in oldPredictionValues) {
    NSNumber *oldPredictionValueObject =
        [oldPredictionValues objectForKey:label];
    const float oldPredictionValue = [oldPredictionValueObject floatValue];
    if (oldPredictionValue > 0.05f) {
      NSDictionary *entry = @{
        @"label" : label,
        @"value" : oldPredictionValueObject
      };
      candidateLabels = [candidateLabels arrayByAddingObject:entry];
    }
  }
  NSSortDescriptor *sort =
      [NSSortDescriptor sortDescriptorWithKey:@"value" ascending:NO];
  NSArray *sortedLabels = [candidateLabels
      sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];

  const float leftMargin = 10.0f;
  const float topMargin = 10.0f;

  const float valueWidth = 48.0f;
  const float valueHeight = 26.0f;

  const float labelWidth = 246.0f;
  const float labelHeight = 26.0f;

  const float labelMarginX = 5.0f;
  const float labelMarginY = 5.0f;

  [self removeAllLabelLayers];

  int labelCount = 0;
  for (NSDictionary *entry in sortedLabels) {
    NSString *label = [entry objectForKey:@"label"];
    NSNumber *valueObject = [entry objectForKey:@"value"];
    const float value = [valueObject floatValue];

    const float originY =
        (topMargin + ((labelHeight + labelMarginY) * labelCount));

    const int valuePercentage = (int)roundf(value * 100.0f);

    const float valueOriginX = leftMargin;
    NSString *valueText = [NSString stringWithFormat:@"%d%%", valuePercentage];

    [self addLabelLayerWithText:valueText
                        originX:valueOriginX
                        originY:originY
                          width:valueWidth
                         height:valueHeight
                      alignment:kCAAlignmentRight];

    const float labelOriginX = (leftMargin + valueWidth + labelMarginX);

    [self addLabelLayerWithText:[label capitalizedString]
                        originX:labelOriginX
                        originY:originY
                          width:labelWidth
                         height:labelHeight
                      alignment:kCAAlignmentLeft];

 
    if ((labelCount == 0) && (value > 0.5f)) {
      [self speak:[label capitalizedString]];
    }
 
    labelCount += 1;
    if (labelCount > 4) {
      break;
    }
  }
}

- (void)removeAllLabelLayers {
  for (CATextLayer *layer in labelLayers) {
    [layer removeFromSuperlayer];
  }
  [labelLayers removeAllObjects];
}

- (void)addLabelLayerWithText:(NSString *)text
                      originX:(float)originX
                      originY:(float)originY
                        width:(float)width
                       height:(float)height
                    alignment:(NSString *)alignment {
  NSString *const font = @"Menlo-Regular";
  const float fontSize = 20.0f;

  const float marginSizeX = 5.0f;
  const float marginSizeY = 2.0f;

  const CGRect backgroundBounds = CGRectMake(originX, originY, width, height);

  const CGRect textBounds =
      CGRectMake((originX + marginSizeX), (originY + marginSizeY),
                 (width - (marginSizeX * 2)), (height - (marginSizeY * 2)));

  CATextLayer *background = [CATextLayer layer];
  [background setBackgroundColor:[UIColor blackColor].CGColor];
  [background setOpacity:0.5f];
  [background setFrame:backgroundBounds];
  background.cornerRadius = 5.0f;

  [[self.view layer] addSublayer:background];
  [labelLayers addObject:background];

  CATextLayer *layer = [CATextLayer layer];
  [layer setForegroundColor:[UIColor whiteColor].CGColor];
  [layer setFrame:textBounds];
  [layer setAlignmentMode:alignment];
  [layer setWrapped:YES];
  [layer setFont:font];
  [layer setFontSize:fontSize];
  layer.contentsScale = [[UIScreen mainScreen] scale];
  [layer setString:text];

  [[self.view layer] addSublayer:layer];
  [labelLayers addObject:layer];
}

- (void)setPredictionText:(NSString *)text withDuration:(float)duration {
  if (duration > 0.0) {
    CABasicAnimation *colorAnimation =
        [CABasicAnimation animationWithKeyPath:@"foregroundColor"];
    colorAnimation.duration = duration;
    colorAnimation.fillMode = kCAFillModeForwards;
    colorAnimation.removedOnCompletion = NO;
    colorAnimation.fromValue = (id)[UIColor darkGrayColor].CGColor;
    colorAnimation.toValue = (id)[UIColor whiteColor].CGColor;
    colorAnimation.timingFunction =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.predictionTextLayer addAnimation:colorAnimation
                                    forKey:@"colorAnimation"];
  } else {
    self.predictionTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
  }

  [self.predictionTextLayer removeFromSuperlayer];
  [[self.view layer] addSublayer:self.predictionTextLayer];
  [self.predictionTextLayer setString:text];
}
 
 */

@end
