public class UserInfo {
    
    public static String UserLogin(string FirstName,string LastName){
        String LoginName = FirstName + '.' + LastName;
        system.debug(LoginName);
        return LoginName;
    }
    
    public static String NewUserLogin(string FirstName,string LastName, string recordID){
         string LoginName = FirstName + '.' + LastName + recordID.substring(12,15);
         system.debug('Username: ' + LoginName);
         return LoginName;
    }
    public static String UserPassword(string FirstName,string LastName, string recordID) {
       string password = FirstName + LastName + recordID.substring(12,15);
       system.debug('Password: ' + password);
       return password;
    }    
}