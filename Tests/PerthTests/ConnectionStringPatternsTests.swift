import Testing
@testable import PerthCore

@Suite("ConnectionStringPatterns")
struct ConnectionStringPatternsTests {
    let detector = ConnectionStringPatterns()

    // MARK: - JDBC

    @Test("detects JDBC connection string with credentials")
    func detectsJDBCConnectionStringWithCredentials() {
        let matches = detector.detect(in: "jdbc:mysql://user:password@localhost:3306/mydb")
        #expect(!matches.isEmpty)
        #expect(matches.allSatisfy { $0.patternType == .connectionString })
    }

    @Test("does not detect JDBC connection string without credentials")
    func doesNotDetectJDBCWithoutCredentials() {
        let matches = detector.detect(in: "jdbc:mysql://localhost:3306/mydb")
        #expect(matches.isEmpty)
    }

    // MARK: - MongoDB

    @Test("detects MongoDB connection string with credentials")
    func detectsMongoDBConnectionStringWithCredentials() {
        let matches = detector.detect(in: "mongodb://admin:s3cr3t@mongo.example.com:27017/mydb")
        #expect(!matches.isEmpty)
    }

    @Test("detects mongodb+srv connection string with credentials")
    func detectsMongoDBSrvConnectionString() {
        let matches = detector.detect(in: "mongodb+srv://user:pass@cluster.mongodb.net/db")
        #expect(!matches.isEmpty)
    }

    @Test("does not detect MongoDB URI without credentials")
    func doesNotDetectMongoDBWithoutCredentials() {
        let matches = detector.detect(in: "mongodb://localhost:27017/mydb")
        #expect(matches.isEmpty)
    }

    // MARK: - PostgreSQL

    @Test("detects postgres:// connection string with credentials")
    func detectsPostgresConnectionString() {
        let matches = detector.detect(in: "postgres://user:password@localhost:5432/mydb")
        #expect(!matches.isEmpty)
    }

    @Test("detects postgresql:// connection string with credentials")
    func detectsPostgreSQLConnectionString() {
        let matches = detector.detect(in: "postgresql://admin:secret@db.example.com/production")
        #expect(!matches.isEmpty)
    }

    // MARK: - MySQL

    @Test("detects mysql:// connection string with credentials")
    func detectsMySQLConnectionString() {
        let matches = detector.detect(in: "mysql://root:root_password@127.0.0.1:3306/app_db")
        #expect(!matches.isEmpty)
    }

    // MARK: - Redis

    @Test("detects Redis connection string with password")
    func detectsRedisConnectionStringWithPassword() {
        let matches = detector.detect(in: "redis://:myredispassword@redis.example.com:6379")
        #expect(!matches.isEmpty)
    }

    // MARK: - ADO.NET style

    @Test("detects ADO.NET style connection string with Password= keyword")
    func detectsADONETConnectionStringWithPasswordKeyword() {
        let matches = detector.detect(in: "Server=myserver.database.windows.net; Password=MyP@ssw0rd")
        #expect(!matches.isEmpty)
    }

    @Test("detects ADO.NET style connection string with Pwd= keyword")
    func detectsADONETConnectionStringWithPwdKeyword() {
        let matches = detector.detect(in: "Data Source=myserver; Pwd=secureP@ss")
        #expect(!matches.isEmpty)
    }

    // MARK: - Edge cases

    @Test("empty input returns no matches")
    func emptyInputReturnsNoMatches() {
        #expect(detector.detect(in: "").isEmpty)
    }

    @Test("connection string snippet is redacted")
    func matchedSnippetIsRedacted() {
        let matches = detector.detect(in: "postgres://user:secretpassword@localhost/db")
        #expect(!matches.isEmpty)
        #expect(!matches[0].matchedSnippet.contains("secretpassword"))
    }
}
