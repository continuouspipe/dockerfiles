var conn;
var attempts = 0;

do {
    try {
        attempts++;
        conn = new Mongo("localhost:27017");
    } catch (e) {
        sleep(100);

        if (attempts > 100) {
            throw e;
        }
    }
} while (conn === undefined)
