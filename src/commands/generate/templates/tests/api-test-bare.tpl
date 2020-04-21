const { request } = require('supertest');
const jsf = require('json-schema-faker');
const expect = require('chai').expect;
const schema = require('../../../api/models/schema/amibo').schema;
jsf.extend('faker', () => require('faker'));

jsf.option('optionalsProbability', 0.3);
const entity = '<%= entity %>';

// @ts-ignore
const esails = global.esails;

console.log('TESTS:: Starting tests on ', entity);

describe(entity.toUpperCase() + ' APIS :: ', () => {
  let testStore: any = {};
  before(async () => {
    const data = {
      // insert your test preparation data here
    };
    const response: any = await request(esails.app)
      .post('/api/' + entity)
      .set('Authorization', 'Bearer ' + esails.config.auth)
      .send(data);

    testStore.savedData = response.body['body'];
  });
  // POST
  describe('#POST() :: ', () => {
    describe('WITHOUT TOKEN :: ', () => {
      it('should give 401 error', (done) => {
        const data = jsf.generate(schema);
        request(esails.app)
          .post('/api/' + entity)
          .set('Authorization', 'Bearer ' + global.testConfig.someApiAuth)
          .send(data)
          .expect(401)
          .then((response: any) => {
            expect(response.body['body']).to.be.undefined;
            done();
          })
          .catch((err: Error) => {
            console.error(err);
            done(err);
          });
      });
    });
  });
});
