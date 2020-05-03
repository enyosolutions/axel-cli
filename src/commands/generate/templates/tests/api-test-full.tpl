import request from 'supertest';
import faker from 'faker';
const jsf = require('json-schema-faker');
import {expect} from 'chai';

const model = require('../../src/api/models/schema/<%= entity %>');

jsf.extend('faker', () => faker);
jsf.option('optionalsProbability', 0.3);

// @ts-ignore
const esails = global.esails;
// @ts-ignore
const testConfig = global.testConfig;



describe('<%= entity %> APIS TESTING :: ', () => {
  let testStore: any = {};
  const entity = '<%= entity %>';
  const entityApiUrl = '/api/<%= entityApiUrl || entity %>';
  const primaryKey = esails.config.framework.primaryKey;

  console.log('TESTS:: Starting tests on ', entity);
  before('BEFORE TESTS', (done) => {
    const data = jsf.generate(model.schema);
      request(esails.app)
        .post(entityApiUrl)
        .set('Authorization', 'Bearer ' + esails.config.auth)
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
        request(esails.app)
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
            request(esails.app)
              .post(entityApiUrl)
              .set('Authorization', 'Bearer ' + esails.config.auth)
              .send(data)
              .expect(400)
              .then((response: any) => {
                expect(response.body['body']).to.be.undefined;
                done();
              })
              .catch((err: Error) => {
                esails.logger.error(err);
                done(err);
              });
          });
        });
      });
    });

    describe('WITH PROPER DATA :: ', () => {
      it('should add values and return the data', (done) => {
        const data = jsf.generate(model.schema);
        request(esails.app)
          .post(entityApiUrl)
          .set('Authorization', 'Bearer ' + esails.config.auth)
          .send(data)
          .expect(200)
          .then((response: any) => {
            expect(response.body['body']).to.not.be.undefined;
            for (const key in response.body['body']) {
              if ([primaryKey, 'lastModifiedOn', 'createdOn'].indexOf(key) !== -1) {
                continue;
              }
              expect(response.body['body'][key]).to.equals(data[key] as any);
            }
            done();
          })
          .catch((err: Error) => {
            esails.logger.error(err);
            done(err);
          });
      });

      // ADD SECOND DATA WITH DIFFERENT POST VALUES
      it('should add values and return the data', (done) => {
        const data = jsf.generate(model.schema);
        request(esails.app)
          .post(entityApiUrl)
          .set('Authorization', 'Bearer ' + esails.config.auth)
          .send(data)
          .expect(200)
          .then((response: any) => {
            expect(response.body['body']).to.not.be.undefined;
            for (const key in response.body['body']) {
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
        request(esails.app)
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
          request(esails.app)
            .get(entityApiUrl)
            .set('Authorization', 'Bearer ' + esails.config.auth)
            .expect(200)
            .then((response: any) => {
              expect(response.body['body']).to.have.length.above(0);
              expect(response.body.page).to.equals(0);
              expect(response.body.count).to.equals(
                esails.config.framework.defaultPagination
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
          request(esails.app)
            .get(entityApiUrl + '?listOfValues=true')
            .set('Authorization', 'Bearer ' + esails.config.auth)
            .expect(200)
            .then((response: any) => {
              expect(response.body['body']).to.have.length.above(0);
              expect(response.body.page).to.equals(0);
              expect(response.body.count).to.equals(
                esails.config.framework.defaultLovPagination
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
        request(esails.app)
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
        request(esails.app)
          .put(entityApiUrl + '/wrong' + testStore.savedData[primaryKey])
          .set('Authorization', 'Bearer ' + esails.config.auth)
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
          request(esails.app)
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
          request(esails.app)
            .get(entityApiUrl + '/wrong' + testStore.savedData[primaryKey])
            .set('Authorization', 'Bearer ' + esails.config.auth)
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
        it('should return value', (done) => {
          request(esails.app)
            .get(entityApiUrl + '/' + testStore.savedData[primaryKey])
            .set('Authorization', 'Bearer ' + esails.config.auth)
            .expect(200)
            .then((response: any) => {
              for (const key in response.body['body']) {
                if (
                  [primaryKey, 'lastModifiedOn', 'createdOn'].indexOf(key) !== -1
                ) {
                  continue;
                }
                console.warn(
                  key,
                  response.body['body'][key],
                  testStore.savedData[key]
                );
                expect(response.body['body'][key]).to.equals(
                  testStore.savedData[key]
                );
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
          request(esails.app)
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
          request(esails.app)
            .delete(entityApiUrl + '/wrong' + testStore.savedData[primaryKey])
            .set('Authorization', 'Bearer ' + esails.config.auth)
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
        it('should return value', (done) => {
          request(esails.app)
            .delete(entityApiUrl + '/' + testStore.savedData[primaryKey])
            .set('Authorization', 'Bearer ' + esails.config.auth)
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
          request(esails.app)
            .get(entityApiUrl + '/' + testStore.savedData[primaryKey])
            .set('Authorization', 'Bearer ' + esails.config.auth)
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
