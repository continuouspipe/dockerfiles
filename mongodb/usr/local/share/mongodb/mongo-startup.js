var conn;
try {
    conn = new Mongo("localhost:27017");
} catch(Error) {
    
}
while (conn===undefined) {
    try {
        conn = new Mongo("localhost:27017");
    } catch(Error) {

    }
    sleep(100);
}
