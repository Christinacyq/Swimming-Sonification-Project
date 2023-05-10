enum NotificationType {Glide, Outsweep, Catch, Insweep, Recovery}

class Notification {
   
  int timestamp;
  NotificationType type; // glide, outsweep, catch, insweep, recovery
  int force;
  float accuracy;
  int duration;
  float oxygen;
  
  public Notification(JSONObject json) {
    this.timestamp = json.getInt("timestamp");
    //time in milliseconds for playback from sketch start
    
    String typeString = json.getString("phase");
    
    try {
      this.type = NotificationType.valueOf(typeString);
    }
    catch (IllegalArgumentException e) {
      throw new RuntimeException(typeString + " is not a valid value for enum NotificationType.");
    }  
    this.force = json.getInt("force");
    this.accuracy = json.getFloat("accuracy");
    this.duration = json.getInt("duration");
    this.oxygen = json.getFloat("oxygen");
    
  }
  
  public int getTimestamp() { return timestamp; }
  public NotificationType getType() { return type; }
  public int getForce() { return force; }
  public float getAccuracy() { return accuracy; }
  public int getDuration() { return duration; }
  public float getOxygen() {return oxygen; }
  
  public String toString() {
      String output = getType().toString() + ": ";
      output += "(force: " + getForce() + ") ";
      output += "( oxygen: " + getOxygen() + ") ";
      output += "(duration: " + getDuration() + ") ";
      output += "(accuracy: " + getAccuracy() + ") ";
      return output;
    }
}
