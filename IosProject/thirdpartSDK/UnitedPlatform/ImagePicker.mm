#include "ImagePicker.h"
//--------------------------------------------------
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import  "ImagePickerViewController.h"
#import  "RootViewController.h"
#endif
//--------------------------------------------------
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#define JAVA_CLASS              "org/cocos2dx/cpp/ImagePicker"
#define JAVA_FUNC_OPEN_PHOTO    "openPhoto"
#define JAVA_FUNC_OPEN_CAMERA   "openCamera"
#endif
//--------------------------------------------------
USING_NS_CC;
//--------------------------------------------------
ImagePicker* ImagePicker::s_instance = NULL;
//--------------------------------------------------
ImagePicker* ImagePicker::getInstance()
{
    if (s_instance == NULL)
    {
        s_instance = new ImagePicker();
    }
    return s_instance;
}
//--------------------------------------------------
void ImagePicker::destoryInstance()
{
    CC_SAFE_DELETE(s_instance);
}
//--------------------------------------------------
ImagePicker::ImagePicker()
:m_callback(nullptr)
{
    Director::getInstance()->getEventDispatcher()->addCustomEventListener("ImagePickerEvent", [=](EventCustom* eve)
    {
        std::string* path = (std::string*)eve->getUserData();
        if (path && m_callback != nullptr)
        {
            m_callback(*path);
        }
    });
}
//--------------------------------------------------
void ImagePicker::callImagePickerWithPhotoAndCamera()
{
    s_instance->init();
//    setListener(callback);
}
//--------------------------------------------------
void ImagePicker::setListener(const std::function<void(std::string)>& callback)
{
    m_callback = callback;
}
//--------------------------------------------------
void ImagePicker::removeListener()
{
    m_callback = nullptr;
}
//--------------------------------------------------
void ImagePicker::openPhoto()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    ImagePickerViewController* imagePickerViewController = [[ImagePickerViewController alloc] initWithNibName:nil bundle:nil];
    
    RootViewController* _viewController = (RootViewController*)m_viewController;
    [_viewController.view addSubview:imagePickerViewController.view];
    
    [imagePickerViewController localPhoto];
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo info;
    bool ret = JniHelper::getStaticMethodInfo(info, JAVA_CLASS, JAVA_FUNC_OPEN_PHOTO,"()V");
    if (ret)
    {
        info.env->CallStaticVoidMethod(info.classID, info.methodID);
    }
#endif
}
//--------------------------------------------------
void ImagePicker::openCamera()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    ImagePickerViewController* imagePickerViewController = [[ImagePickerViewController alloc] initWithNibName:nil bundle:nil];
    
    RootViewController* _viewController = (RootViewController*)m_viewController;
    [_viewController.view addSubview:imagePickerViewController.view];
    
    [imagePickerViewController takePhoto];
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo info;
    bool ret = JniHelper::getStaticMethodInfo(info, JAVA_CLASS, JAVA_FUNC_OPEN_CAMERA,"()V");
    if (ret)
    {
        info.env->CallStaticVoidMethod(info.classID, info.methodID);
    }
#endif
}
//--------------------------------------------------
bool ImagePicker::init()
{
    cocos2d::Size visibleSize = Director::getInstance()->getVisibleSize();
    
    //-------------------------------------
    // 根层
    //-------------------------------------
    LayerColor* m_layer = LayerColor::create(Color4B(0, 0, 0, 125));
    m_layer->retain();
    //-------------------------------------
    // 按钮背景
    //-------------------------------------
    Sprite* sprite = Sprite::create("ImagePicker/bk.png");
    sprite->setAnchorPoint(Vec2(0.5, 0));
    sprite->setPosition(Vec2(visibleSize.width/2, 0));
    m_layer->addChild(sprite);
    //-------------------------------------
    // 按钮
    //-------------------------------------
    Menu* menu = Menu::create();
    menu->setPosition(Vec2::ZERO);
    m_layer->addChild(menu);
    //-------------------------------------
    MenuItemImage* btnPhoto  = MenuItemImage::create("ImagePicker/ButtonPhoto.png",  "ImagePicker/ButtonPhoto1.png",  [=](Ref* p)
    {
        openPhoto();
    });
    btnPhoto->setAnchorPoint(Vec2(0.5, 1));
    btnPhoto->setPosition(Vec2(visibleSize.width / 2, 280));
    menu->addChild(btnPhoto);
    //-------------------------------------
    MenuItemImage* btnCamera = MenuItemImage::create("ImagePicker/ButtonCamera.png", "ImagePicker/ButtonCamera1.png", [=](Ref* p)
    {
        openCamera();
    });
    btnCamera->setAnchorPoint(Vec2(0.5, 1));
    btnCamera->setPosition(btnPhoto->getPosition() + Vec2(0, -btnPhoto->getContentSize().height));
    menu->addChild(btnCamera);
    //-------------------------------------
    MenuItemImage* btnCancel = MenuItemImage::create("ImagePicker/ButtonCancel.png", "ImagePicker/ButtonCancel1.png", [=](Ref* p)
    {
        float height = sprite->getContentSize().height;

        MoveBy* move = MoveBy::create(0.2, Vec2(0, -height));
        sprite->runAction(move);
        menu  ->runAction(move->clone());

        Sequence* seq = Sequence::createWithTwoActions(FadeOut::create(0.2), RemoveSelf::create());
        m_layer->runAction(seq);
    });
    btnCancel->setAnchorPoint(Vec2(0.5, 1));
    btnCancel->setPosition(btnCamera->getPosition() + Vec2(0, -btnCamera->getContentSize().height - 20));
    menu->addChild(btnCancel);
    //-------------------------------------
    // 文字
    //-------------------------------------
    Label* textPhoto  = Label::createWithSystemFont("Photo",  "", 24);
    textPhoto->setPosition(btnPhoto->getContentSize() / 2);
    textPhoto->setTextColor(Color4B::BLACK);
    btnPhoto->addChild(textPhoto);
    //-------------------------------------
    Label* textCamera = Label::createWithSystemFont("Camera", "", 24);
    textCamera->setPosition(btnPhoto->getContentSize() / 2);
    textCamera->setTextColor(Color4B::BLACK);
    btnCamera->addChild(textCamera);
    //-------------------------------------
    Label* textCancel = Label::createWithSystemFont("Cancel", "", 24);
    textCancel->setPosition(btnPhoto->getContentSize() / 2);
    textCancel->setTextColor(Color4B::BLACK);
    btnCancel->addChild(textCancel);
    //-------------------------------------
    // 准备显示
    //-------------------------------------
    Director::getInstance()->getRunningScene()->scheduleOnce([=](float time)
    {
        Director::getInstance()->getRunningScene()->addChild(m_layer, INT_MAX);
        m_layer->release();

        float height = sprite->getContentSize().height;

        sprite->setPositionY(sprite->getPositionY() - height);
        menu  ->setPositionY(menu->getPositionY()   - height);

        MoveBy* move = MoveBy::create(0.3, Vec2(0, height));
        sprite->runAction(move);
        menu  ->runAction(move->clone());

        m_layer->setOpacity(0);
        m_layer->runAction(FadeTo::create(0.2, 125));

    }, 0.1, "ImagePickerScheduleOnce");
    //-------------------------------------
    // 截断事件
    //-------------------------------------
    EventListenerTouchOneByOne* touchEvent = EventListenerTouchOneByOne::create();
    touchEvent->setSwallowTouches(true);
    touchEvent->onTouchBegan = [=](Touch* touch, Event* eve)
    {
        if(sprite->getBoundingBox().containsPoint(touch->getLocation()))
            return true;
        
        float height = sprite->getContentSize().height;
        
        MoveBy* move = MoveBy::create(0.2, Vec2(0, -height));
        sprite->runAction(move);
        menu  ->runAction(move->clone());
        
        Sequence* seq = Sequence::createWithTwoActions(FadeOut::create(0.2), RemoveSelf::create());
        m_layer->runAction(seq);
        
        return true;
    };
    Director::getInstance()->getEventDispatcher()->addEventListenerWithSceneGraphPriority(touchEvent, sprite);
    //-------------------------------------
    return true;
}
//--------------------------------------------------
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
void  ImagePicker::setViewController(void* viewController)
{
    m_viewController = viewController;
}
#endif
//--------------------------------------------------
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
extern "C"
{
    void Java_org_cocos2dx_cpp_ImagePicker_onImageSaved(JNIEnv* env, jobject thiz, jstring path)
    {
        std::string strPath = JniHelper::jstring2string(path);
        Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("ImagePickerEvent", &strPath);
    }
}
#endif
//--------------------------------------------------