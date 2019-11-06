import java.sql.*;
// You should use this class so that you can represent SQL points as
// Java PGpoint objects.
import org.postgresql.geometric.PGpoint;

public class Assignment2 {

   // A connection to the database
   Connection connection;

   Assignment2() throws SQLException {
      try {
         Class.forName("org.postgresql.Driver");
      } catch (ClassNotFoundException e) {
         e.printStackTrace();
      }
   }

  /**
   * Connects and sets the search path.
   *
   * Establishes a connection to be used for this session, assigning it to
   * the instance variable 'connection'.  In addition, sets the search
   * path to uber, public.
   *
   * @param  url       the url for the database
   * @param  username  the username to connect to the database
   * @param  password  the password to connect to the database
   * @return           true if connecting is successful, false otherwise
   */
   public boolean connectDB(String URL, String username, String password) {
      // Implement this method!
      return false;
   }

  /**
   * Closes the database connection.
   *
   * @return true if the closing was successful, false otherwise
   */
   public boolean disconnectDB() {
      // Implement this method!
      return false;
   }
   
   /* ======================= Driver-related methods ======================= */

   /**
    * Records the fact that a driver has declared that he or she is available 
    * to pick up a client.  
    *
    * Does so by inserting a row into the Available table.
    * 
    * @param  driverID  id of the driver
    * @param  when      the date and time when the driver became available
    * @param  location  the coordinates of the driver at the time when 
    *                   the driver became available
    * @return           true if the insertion was successful, false otherwise. 
    */
   public boolean available(int driverID, Timestamp when, PGpoint location) {
      // Implement this method!
      return false;
   }

   /**
    * Records the fact that a driver has picked up a client.
    *
    * If the driver was dispatched to pick up the client and the corresponding
    * pick-up has not been recorded, records it by adding a row to the
    * Pickup table, and returns true.  Otherwise, returns false.
    * 
    * @param  driverID  id of the driver
    * @param  clientID  id of the client
    * @param  when      the date and time when the pick-up occurred
    * @return           true if the operation was successful, false otherwise
    */
   public boolean picked_up(int driverID, int clientID, Timestamp when) {
      // Implement this method!
      return false;
   }
   
   /* ===================== Dispatcher-related methods ===================== */

   /**
    * Dispatches drivers to the clients who've requested rides in the area
    * bounded by NW and SE.
    * 
    * For all clients who have requested rides in this area (i.e., whose 
    * request has a source location in this area), dispatches drivers to them
    * one at a time, from the client with the highest total billings down
    * to the client with the lowest total billings, or until there are no
    * more drivers available.
    *
    * Only drivers who (a) have declared that they are available and have 
    * not since then been dispatched, and (b) whose location is in the area
    * bounded by NW and SE, are dispatched.  If there are several to choose
    * from, the one closest to the client's source location is chosen.
    * In the case of ties, any one of the tied drivers may be dispatched.
    *
    * Area boundaries are inclusive.  For example, the point (4.0, 10.0) 
    * is considered within the area defined by 
    *         NW = (1.0, 10.0) and SE = (25.0, 2.0) 
    * even though it is right at the upper boundary of the area.
    *
    * Dispatching a driver is accomplished by adding a row to the
    * Dispatch table.  All dispatching that results from a call to this
    * method is recorded to have happened at the same time, which is
    * passed through parameter 'when'.
    * 
    * @param  NW    x, y coordinates in the northwest corner of this area.
    * @param  SE    x, y coordinates in the southeast corner of this area.
    * @param  when  the date and time when the dispatching occurred
    */
   public void dispatch(PGpoint NW, PGpoint SE, Timestamp when) {
      // Implement this method!
   }

   public static void main(String[] args) {
      // You can put testing code in here. It will not affect our autotester.
      System.out.println("Boo!");
   }

}
