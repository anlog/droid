import android.os.Handler;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * author: dp
 * created on: 2019-09-26 10:26
 * description:
 */
public class AppUtils {

    public static int PAUSE_ACTIVITY = 0;
    public static int RESUME_ACTIVITY = 0;
    private static final Handler mH = getHandler();

    public synchronized static Handler getHandler() {
        if (mH != null) {
            return mH;
        }
        Object activityThread;
        try {
            Class<?> acActivityThread = Class.forName("android.app.ActivityThread");
            if (acActivityThread == null) {
                Logger.dF("ActivityThread => acActivityThread - null");
                return null;
            }
            Method acActivityThreadCurrentActivityThread = acActivityThread.getMethod("currentActivityThread");
            if (acActivityThreadCurrentActivityThread == null) {
                Logger.dF("ActivityThread => acActivityThreadCurrentActivityThread - null");
                return null;
            }
            if (!acActivityThreadCurrentActivityThread.isAccessible()) {
                acActivityThreadCurrentActivityThread.setAccessible(true);
            }
            activityThread = acActivityThreadCurrentActivityThread.invoke(null);
            if (activityThread == null) {
                Logger.dF("ActivityThread => activityThread - null");
                return null;
            }
            Method getHandler = activityThread.getClass().getDeclaredMethod("getHandler");
            if (getHandler == null) {
                Logger.dF("ActivityThread => getHandler - null");
                return null;
            }
            if (!getHandler.isAccessible()) {
                getHandler.setAccessible(true);
            }
            Object invokedHandler = getHandler.invoke(activityThread);
            if (invokedHandler == null) {
                Logger.dF("ActivityThread => invokedHandler - null");
                return null;
            }
            Field mRESUME_ACTIVITY = invokedHandler.getClass().getField("RESUME_ACTIVITY");
            if (mRESUME_ACTIVITY == null) {
                Logger.dF("ActivityThread => mRESUME_ACTIVITY - null");
                return null;
            }
            if (!mRESUME_ACTIVITY.isAccessible()) {
                mRESUME_ACTIVITY.setAccessible(true);
            }
            RESUME_ACTIVITY = (int) mRESUME_ACTIVITY.get(invokedHandler);

            Field mPAUSE_ACTIVITY = invokedHandler.getClass().getField("PAUSE_ACTIVITY");
            if (mPAUSE_ACTIVITY == null) {
                Logger.dF("ActivityThread => mPAUSE_ACTIVITY - null");
                return null;
            }
            PAUSE_ACTIVITY = (int) mPAUSE_ACTIVITY.get(invokedHandler);

            Logger.dF("ActivityThread => RESUME_ACTIVITY: %d - PAUSE_ACTIVITY: %d", RESUME_ACTIVITY, PAUSE_ACTIVITY);

            Handler mH = (Handler) invokedHandler;
            Logger.dF("ActivityThread: mH - %s", mH.toString());
            return mH;
        } catch (ClassNotFoundException | NoSuchFieldException | NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
            e.printStackTrace();
        }
        return null;
    }
}
