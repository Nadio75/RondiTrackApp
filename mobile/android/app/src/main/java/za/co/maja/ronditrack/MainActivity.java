package za.co.maja.ronditrack;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;
import android.os.Bundle;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        createPrivateNotificationChannel();
        super.onCreate(savedInstanceState);
    }

    private void createPrivateNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            NotificationChannel channel =
                new NotificationChannel(
                    "ronditrack_updates",
                    "RondiTrack updates",
                    NotificationManager.IMPORTANCE_HIGH
                );

            channel.setDescription(
                "General application updates"
            );

            channel.setLockscreenVisibility(
                Notification.VISIBILITY_PRIVATE
            );

            NotificationManager manager =
                getSystemService(NotificationManager.class);

            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
        }
    }
}
