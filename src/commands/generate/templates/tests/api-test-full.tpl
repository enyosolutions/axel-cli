const request = require('supertest');
const jsf = require('json-schema-faker');
const expect = require('chai').expect;
const schema = require('../../src/api/models/schema/amibo').schema;
jsf.extend('faker', () => require('faker'));

jsf.option('optionalsProbability', 0.3);
const entity = '<%= entity %>';

// @ts-ignore
const esails = global.esails;

console.log('TESTS:: Starting tests on ', entity);

describe(entity.toUpperCase() + ' APIS TESTING :: ', () => {
  let testStore: any = {};
  before('BEFORE TESTS', async (done) => {
    const data = jsf.generate(schema);
    try {
      const response: any = await request(esails.app)
        .post('/api/' + entity)
        .set('Authorization', 'Bearer ' + esails.config.auth)
        .send(data);

      testStore.savedData = response.body['body'];
      done();
    } catch (err) {
      console.error(err.message);
      done(err);
    }
  });
  // POST
  describe('#POST() :: ', () => {
    describe('WITHOUT TOKEN :: ', () => {
      it('should give 401 error', (done) => {
        const data = jsf.generate(schema);
        request(esails.app)
          .post('/api/' + entity)
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
      schema.required.forEach((field: string) => {
        describe(field + ' :: ', () => {
          it('should give 400 error', (done) => {
            const data = jsf.generate(schema);
            delete data[field];
            request(esails.app)
              .post('/api/' + entity)
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
        const data = jsf.generate(schema);
        request(esails.app)
          .post('/api/' + entity)
          .set('Authorization', 'Bearer ' + esails.config.auth)
          .send(data)
          .expect(200)
          .then((response: any) => {
            expect(response.body['body']).to.not.be.undefined;
            for (const key in response.body['body']) {
              if (['_id', 'lastModifiedOn', 'createdOn'].indexOf(key) !== -1) {
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
        const data = jsf.generate(schema);
        request(esails.app)
          .post('/api/' + entity)
          .set('Authorization', 'Bearer ' + esails.config.auth)
          .send(data)
          .expect(200)
          .then((response: any) => {
            expect(response.body['body']).to.not.be.undefined;
            for (const key in response.body['body']) {
              if (['_id', 'lastModifiedOn', 'createdOn'].indexOf(key) !== -1) {
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
          .get('/api/' + entity)
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
            .get('/api/' + entity)
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
            .get('/api/' + entity + '?listOfValues=true')
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
        const data = jsf.generate(schema);
        request(esails.app)
          .put('/api/' + entity + '/' + testStore.savedData._id)
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
        const data = jsf.generate(schema);
        request(esails.app)
          .put('/api/' + entity + '/wrong' + testStore.savedData._id)
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
            .get('/api/' + entity + '/' + testStore.savedData._id)
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
            .get('/api/' + entity + '/wrong' + testStore.savedData._id)
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
            .get('/api/' + entity + '/' + testStore.savedData._id)
            .set('Authorization', 'Bearer ' + esails.config.auth)
            .expect(200)
            .then((response: any) => {
              for (const key in response.body['body']) {
                if (
                  ['_id', 'lastModifiedOn', 'createdOn'].indexOf(key) !== -1
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
            .delete('/api/' + entity + '/' + testStore.savedData._id)
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
            .delete('/api/' + entity + '/wrong' + testStore.savedData._id)
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
            .delete('/api/' + entity + '/' + testStore.savedData._id)
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
            .get('/api/' + entity + '/' + testStore.savedData._id)
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
