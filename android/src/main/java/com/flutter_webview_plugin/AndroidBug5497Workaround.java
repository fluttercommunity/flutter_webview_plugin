package com.flutter_webview_plugin;

import android.app.Activity;
import android.graphics.Rect;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;

/**
 * Description:
 * Author: Jack Zhang
 * create on: 2020-01-08 14:16
 */
public class AndroidBug5497Workaround
{

  // For more information, see https://code.google.com/p/android/issues/detail?id=5497
  // To use this class, simply invoke assistActivity() on an Activity that already has its content view set.

  public static void assistActivity(Activity activity)
  {
    new AndroidBug5497Workaround(activity);
  }

  private View mChildOfContent;
  private int usableHeightPrevious;
  private FrameLayout.LayoutParams frameLayoutParams;

  private AndroidBug5497Workaround(Activity activity)
  {
    //Decorview里分为title和content，content即是承载我们setContentView方法的布局的根布局
    FrameLayout content = (FrameLayout) activity.findViewById(android.R.id.content);
    //mChildOfContent我们setContentView方法的布局
    mChildOfContent = content.getChildAt(0);
    //监听布局变化，任何界面变化都会触发该监听
    //软键盘弹起同样也会触发该监听
    mChildOfContent.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener()
    {
      public void onGlobalLayout()
      {
        possiblyResizeChildOfContent();
      }
    });
    frameLayoutParams = (FrameLayout.LayoutParams) mChildOfContent.getLayoutParams();
  }

  private void possiblyResizeChildOfContent()
  {
    int usableHeightNow = computeUsableHeight();
    if (usableHeightNow != usableHeightPrevious)
    {
      int usableHeightSansKeyboard = mChildOfContent.getRootView().getHeight();
      //计算布局变化的高度
      int heightDifference = usableHeightSansKeyboard - usableHeightNow;
      if (heightDifference > (usableHeightSansKeyboard / 4))
      {
        // keyboard probably just became visible
        //如果布局变化的高度大于全屏高度的4分之一，则认为可能是键盘弹出，需要改变我们setContentView的布局高度
        frameLayoutParams.height = usableHeightSansKeyboard - heightDifference;
      } else
      {
        // keyboard probably just became hidden
        frameLayoutParams.height = usableHeightSansKeyboard;
      }
      //布局改变后重绘
      mChildOfContent.requestLayout();
      usableHeightPrevious = usableHeightNow;
    }
  }

  //计算去掉键盘高度后的可用高度
  private int computeUsableHeight()
  {
    Rect r = new Rect();
    mChildOfContent.getWindowVisibleDisplayFrame(r);
//    return (r.bottom - r.top);
    // 全屏模式下： return r.bottom
    return r.bottom;
  }

}