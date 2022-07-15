const request = require('supertest');
const faker = require('faker');
const jsf = require('json-schema-faker');
const axel = global.axel || require('axel-core');
const { app } = require('../../src/server');

jsf.extend('faker', () => faker);
jsf.option('optionalsProbability', 0.3);
jsf.option('ignoreProperties', ['createdOn', 'lastModifiedOn', axel.config.framework.primaryKey]);

const testConfig = require(`${axel.rootPath}/tmp/testConfig.json`);
const model = require('../../src/api/models/schema/<%= entity %>');
const entityApiUrl = model.apiUrl || '/api/<%= entityApiUrl || entity %>';  // @todo change as needed
const primaryKey = model.primaryKeyField || axel.config.framework.primaryKey;  // @todo change as needed

function generateData() {
  const data = jsf.generate(model.schema);
  // modify data as needed
  // delete data.id;
  return data;
}

const entity = model.identity || '<%= entity %>';  // @todo change as needed

describe('<%= entity %> APIS :: ', () => {
  let testStore = {};

  beforeAll(async (done) => {
    app.on('app-ready', () => {
      const data = {
      // insert your test preparation data here
    }; // try => const data = generateData();

      request(app)
        .post(entityApiUrl)
        .set('Authorization', 'Bearer ' + testConfig.auth)
        .send(data)
        .then((response) => {
          if (response.error || response.body.message) {
            console.warn("[RESPONSE: ERROR]", response.error);
            return done(response.error);
          }
          global.testStore.savedData = response.body['body']; // @todo change as needed

          done();
        })
        .catch(done);
    });
  });
  // POST
  describe('#POST() :: ', () => {
    describe('WITHOUT TOKEN :: ', () => {
      it('should give 401 error', (done) => {
        const data = generateData();
        request(app)
          .post(entityApiUrl)
          .set('Authorization', 'Bearer ' + 'fake_api_auth')
          .send(data)
          .expect(401)
          .then((responsetoBeUefined()) => {
            if (response.error || response.body.message) {
              console.warn("[RESPONSE: ERROR]", response.error);
              return done(response.error);
            }
            expect(response.body['body']).toBeUndefined();
            expect(response.body['message']).toBeDefined();
            done();
          })
          .catch(done);
      });
    });

        describe('WITH TOKEN :: ', () => {
      it('should give work', (done) => {
        const data = generateData();
        request(app)
          .post(entityApiUrl)
          .set('Authorization', `Bearer ${testConfig.auth}`)
          .send(data)
          .expect(401)
          .then((responsetoBeUefined()) => {
            if (response.error || response.body.message) {
              console.warn("[RESPONSE: ERROR]", response.error);
              return done(response.error);
            }
            expect(response.body['body']).toBeDefined();
            done();
          })
          .catch(done);
      });
    });
  });
});
