import request from 'supertest';
import faker from 'faker';
const jsf = require('json-schema-faker');
import {expect} from 'chai';

// @ts-ignore
const axel = global.axel;

const model = require('../../src/api/models/schema/<%= entity %>');

jsf.extend('faker', () => faker);
jsf.option('optionalsProbability', 0.3);
jsf.option('ignoreProperties', ['createdOn', 'lastModifiedOn', axel.config.framework.primaryKey]);

// @ts-ignore
const testConfig = global.testConfig;



describe('<%= entity %> APIS TESTING :: ', () => {
  let testStore: any = {};
  const entity = '<%= entity %>';
  const entityApiUrl = '/api/<%= entityApiUrl || entity %>';
  const primaryKey = axel.config.framework.primaryKey;

  console.log('TESTS:: Starting tests on ', entity);
  before('BEFORE TESTS', (done) => {
    const data = jsf.generate(model.schema);
      request(axel.app)
        .post(entityApiUrl)
        .set('Authorization', 'Bearer ' + testConfig.auth)
        .send(data)
        .then((response: any) => {
           testStore.savedData = response.body['body'];
          done();
        })
        .catch((err: Error) => {
          console.error(err);
          done(err);
        });
  });
  // POST
  describe('#POST() :: ', () => {
    describe('WITHOUT TOKEN :: ', () => {
      it('should give 401 error', (done) => {
        const data = jsf.generate(model.schema);
        request(axel.app)
          .post(entityApiUrl)
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

    describe('WITHOUT FIELD :: ', () => {
      model.schema.required.forEach((field: string) => {
        describe(field + ' :: ', () => {
          it('should give 400 error', (done) => {
            const data = jsf.generate(model.schema);
            delete data[field];
            request(axel.app)
              .post(entityApiUrl)
              .set('Authorization', 'Bearer ' + testConfig.auth)
              .send(data)
              .expect(400)
              .then((response: any) => {
                expect(response.body['body']).to.be.undefined;
                done();
              })
              .catch((err: Error) => {
                axel.logger.error(err);
                done(err);
              });
          });
        });
      });
    });

    describe('WITH PROPER DATA :: ', () => {
      it('should add values and return the data', (done) => {
        const data = jsf.generate(model.schema);
        request(axel.app)
          .post(entityApiUrl)
          .set('Authorization', 'Bearer ' + testConfig.auth)
          .send(data)
          .expect(200)
          .then((response: any) => {
              expect(response.body['body']).to.not.be.undefined;
              expect(response.body['body'][primaryKey]).to.not.be.undefined;
              for (const key in model.schema.required) {
                if ([primaryKey, 'lastModifiedOn', 'createdOn'].indexOf(key) !== -1) {
                  continue;
                }
                expect(response.body['body'][key]).to.equals(data[key] as any);
              }
              done();
          })
          .catch((err: Error) => {
            axel.logger.error(err);
            done(err);
          });
      });

      // ADD SECOND DATA WITH DIFFERENT POST VALUES
      it('should add values and return the data 2', (done) => {
        const data = jsf.generate(model.schema);
        request(axel.app)
          .post(entityApiUrl)
          .set('Authorization', 'Bearer ' + testConfig.auth)
          .send(data)
          .expect(200)
          .then((response: any) => {
              expect(response.body['body']).to.not.be.undefined;
              expect(response.body['body'][primaryKey]).to.not.be.undefined;
              for (const key in model.schema.required) {
                if ([primaryKey, 'lastModifiedOn', 'createdOn'].indexOf(key) !== -1) {
                  continue;
                }
                expect(response.body['body'][key]).to.equals(data[key] as any);
              }
              done();
          })
          .catch((err: Error) => {
            console.error(err);
            done(err);
          });
      });
    });
  });

  // LIST
  describe('#LIST() :: ', () => {
    describe('WITHOUT TOKEN :: ', () => {
      it('should give 401 error', (done) => {
        request(axel.app)
          .get(entityApiUrl)
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

    describe('WITH PROPER DATA :: ', () => {
      describe('WITHOUT LOV :: ', () => {
        it('should give list with default pagination', (done) => {
          request(axel.app)
            .get(entityApiUrl)
            .set('Authorization', 'Bearer ' + testConfig.auth)
            .expect(200)
            .then((response: any) => {
              expect(response.body['body']).to.have.length.above(0);
              expect(response.body.page).to.equals(0);
              expect(response.body.count).to.equals(
                axel.config.framework.defaultPagination
              );
              expect(response.body.totalCount).to.be.above(0);
              done();
            })
            .catch((err: Error) => {
              console.error(err);
              done(err);
            });
        });
      });

      describe('WITH LOV :: ', () => {
        it('should give list with lov pagination', (done) => {
          request(axel.app)
            .get(entityApiUrl + '?listOfValues=true')
            .set('Authorization', 'Bearer ' + testConfig.auth)
            .expect(200)
            .then((response: any) => {
              expect(response.body['body']).to.have.length.above(0);
              expect(response.body.page).to.equals(0);
              expect(response.body.count).to.equals(
                axel.config.framework.defaultLovPagination
              );
              expect(response.body.totalCount).to.be.above(0);
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

  // UPDATE
  describe('#UPDATE() :: ', () => {
    describe('WITHOUT TOKEN :: ', () => {
      it('should give 401 error', (done) => {
        const data = jsf.generate(model.schema);
        request(axel.app)
          .put(entityApiUrl + '/' + testStore.savedData[primaryKey])
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

    describe('WRONG ID :: ', () => {
      it('should give 404 error', (done) => {
        const data = jsf.generate(model.schema);
        request(axel.app)
          .put(entityApiUrl + '/wrong' + testStore.savedData[primaryKey])
          .set('Authorization', 'Bearer ' + testConfig.auth)
          .send(data)
          .expect(404)
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

    // GET
    describe('#GET() :: ', () => {
      describe('WITHOUT TOKEN :: ', () => {
        it('should give 401', (done) => {
          request(axel.app)
            .get(entityApiUrl + '/' + testStore.savedData[primaryKey])
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

      describe('WRONG ID :: ', () => {
        it('should give 404 error', (done) => {
          request(axel.app)
            .get(entityApiUrl + '/wrong' + testStore.savedData[primaryKey])
            .set('Authorization', 'Bearer ' + testConfig.auth)
            .expect(404)
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

      describe('PROPER DATA :: ', () => {
        it('should return value (extended)', (done) => {
          request(axel.app)
            .get(entityApiUrl + '/' + testStore.savedData[primaryKey])
            .set('Authorization', 'Bearer ' + testConfig.auth)
            .expect(200)
            .then((response: any) => {
              expect(response.body['body']).to.not.be.undefined;
              expect(response.body['body'][primaryKey]).to.not.be.undefined;
              for (const key in model.schema.required) {
                if ([primaryKey, 'lastModifiedOn', 'createdOn'].indexOf(key) !== -1) {
                  continue;
                }
                expect(response.body['body'][key]).to.equals(data[key] as any);
              }
              done();
            })
            .catch((err: Error) => {
              console.error(err);
              done(err);
            });
        });
      });
    });

    // DELETE
    describe('#DELETE() :: ', () => {
      describe('WITHOUT TOKEN :: ', () => {
        it('should give 401', (done) => {
          request(axel.app)
            .delete(entityApiUrl + '/' + testStore.savedData[primaryKey])
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

      describe('WRONG ID :: ', () => {
        it('should give 404 error', (done) => {
          request(axel.app)
            .delete(entityApiUrl + '/wrong' + testStore.savedData[primaryKey])
            .set('Authorization', 'Bearer ' + testConfig.auth)
            .expect(404)
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

      describe('PROPER DATA :: ', () => {
        it('should return value (simple)', (done) => {
          request(axel.app)
            .delete(entityApiUrl + '/' + testStore.savedData[primaryKey])
            .set('Authorization', 'Bearer ' + testConfig.auth)
            .expect(200)
            .then((response: any) => {
              expect(response.body.status).to.equals('OK');
              done();
            })
            .catch((err: Error) => {
              console.error(err);
              done(err);
            });
        });
      });

      describe('CHECK IF DELETED :: ', () => {
        it('should give 404 error', (done) => {
          request(axel.app)
            .get(entityApiUrl + '/' + testStore.savedData[primaryKey])
            .set('Authorization', 'Bearer ' + testConfig.auth)
            .expect(404)
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
});
