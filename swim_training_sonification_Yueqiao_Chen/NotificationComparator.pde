import java.util.Comparator;

public class NotificationComparator implements Comparator<Notification> {
    
    //@Override
    public int compare(Notification n1, Notification n2) {
      return min(int(n1.getAccuracy()*10), int(n2.getAccuracy()*10));
    }
}
