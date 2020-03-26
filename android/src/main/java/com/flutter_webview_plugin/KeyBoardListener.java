package com.flutter_webview_plugin;

import android.app.Activity;
import android.graphics.Rect;
import android.util.Log;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;

public class KeyBoardListener {
    private Activity activity;


    private View mChildOfContent;
    private int usableHeightPrevious;
    private int statusHeight = 0;
    private FrameLayout.LayoutParams frameLayoutParams;
    private ViewTreeObserver.OnGlobalLayoutListener layoutListener;

    private static KeyBoardListener keyBoardListener;


    public static KeyBoardListener getInstance(Activity activity) {
        if(keyBoardListener == null) {
            keyBoardListener = new KeyBoardListener(activity);
        }
        return keyBoardListener;
    }


    public KeyBoardListener(Activity activity) {
        super();
        // TODO Auto-generated constructor stub
        this.activity = activity;

    }


    public void init() {
        FrameLayout content = (FrameLayout) activity
                .findViewById(android.R.id.content);
        mChildOfContent = content.getChildAt(0);
        layoutListener = new ViewTreeObserver.OnGlobalLayoutListener() {
            public void onGlobalLayout() {
                possiblyResizeChildOfContent();
            }
        };
        mChildOfContent.getViewTreeObserver().addOnGlobalLayoutListener(layoutListener);
        frameLayoutParams = (FrameLayout.LayoutParams) mChildOfContent
                .getLayoutParams();


    }

    public void uninstall() {
        if (layoutListener != null) {
            mChildOfContent.getViewTreeObserver().removeOnGlobalLayoutListener(layoutListener);
        }

    }


    private void possiblyResizeChildOfContent() {
        int usableHeightNow = computeUsableHeight();

        if (usableHeightNow != usableHeightPrevious) {
            int usableHeightSansKeyboard = mChildOfContent.getRootView()
                    .getHeight();

            int heightDifference = usableHeightSansKeyboard - usableHeightNow;
            if (statusHeight == 0) {
                statusHeight = heightDifference + 1; // the first heightDifference is statusHeight， add 1 solve spacing webview with keyboard
            }
            if (heightDifference > (usableHeightSansKeyboard / 4)) {
                // keyboard probably just became visible
                frameLayoutParams.height = usableHeightSansKeyboard
                        - heightDifference + statusHeight;
            } else {
                // keyboard probably just became hidden
                frameLayoutParams.height = usableHeightSansKeyboard;
            }
            mChildOfContent.requestLayout();
            usableHeightPrevious = usableHeightNow;
        }
    }


    private int computeUsableHeight() {
        Rect r = new Rect();
        mChildOfContent.getWindowVisibleDisplayFrame(r);
        return (r.bottom - r.top);
    }

}
