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

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#include <memory>
#include "tensorflow/core/public/session.h"
#include "tensorflow/core/util/memmapped_file_system.h"

@interface CameraExampleViewController
    : UIViewController<UIGestureRecognizerDelegate> {

        AVCaptureVideoPreviewLayer *previewLayer;
        AVCaptureStillImageOutput *stillImageOutput;
        UIView *flashView;
        AVCaptureSession *session;
        std::unique_ptr<tensorflow::Session> tf_session;
        std::unique_ptr<tensorflow::MemmappedEnv> tf_memmapped_env;
        std::vector<std::string> labels;
        UIView * previewView;
        AVCaptureConnection * conn;
        //获取的图片数据
        CVPixelBufferRef photoPixelBuffer;
        //拍照按钮
        UIButton * photoBtn;
        //提示layer
        CATextLayer * noticeLayer;
        //bounding box类似的方框
        CAShapeLayer * shapeLayer;
}
/**
 *  记录开始的缩放比例
 */
@property(nonatomic,assign)CGFloat beginGestureScale;
/**
 * 最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;

@end
