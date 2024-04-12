
const request = require('supertest');
const app = require('../index');
const chai = require('chai');
const expect = chai.expect;

describe('Authentication Tests', function() {
    describe('Successes', function() {
        it('Return 200 if the database is up', function(done) {
            request(app).get('/healthz').send().end(function(err, res) {
                expect(res.statusCode).to.be.equal(200);
                done();
            });
        });
    });
});