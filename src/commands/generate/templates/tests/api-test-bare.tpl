import request from 'supertest';
import faker from 'faker';
const jsf = require('json-schema-faker');
import {expect} from 'chai';

const model = require('../../src/api/models/schema/<%= entity %>');

jsf.extend('faker', () => faker);
jsf.option('optionalsProbability', 0.3);

// @ts-ignore
const axel = global.axel;
// @ts-ignore
const testConfig = global.testConfig;


describe('<%= entity %> APIS :: ', () => {
  const entity = '<%= entity %>';
  const entityApiUrl = '/api/<%= entityApiUrl || entity %>';
  let testStore: any = {};

  console.log('TESTS:: Starting tests on ', entity);
  before(async () => {
    const data = {
      // insert your test preparation data here
    };
    const response: any = await request(axel.app)
      .post(entityApiUrl)
      .set('Authorization', 'Bearer ' + testConfig.someApiAuth)
      .send(data);

    testStore.savedData = response.body['body'];
  });
  // POST
  describe('#POST() :: ', () => {
    describe('WITHOUT TOKEN :: ', () => {
      it('should give 401 error', (done) => {
        const data = jsf.generate(model.schema);
        request(axel.app)
          .post(entityApiUrl)
          .set('Authorization', 'Bearer ' + 'fake_api_auth')
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
