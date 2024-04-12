const { KubeConfig, CoreV1Api, CustomObjectsApi } = require('@kubernetes/client-node');
const axios = require('axios');

const db = require("../services/service");

const HttpCheck = require("../models/HttpCheck");

const healthz = async (req, res) => {

    if (Object.keys(req.query).length > 0 || req.headers["content-length"] > 0) {
        return res.status(400).end();
    }
    
    db.authenticate()
    .then(() => {
        res.status(200).set("Cache-Control", "no-cache").end();
    })
    .catch((error) => {
        res.status(503).set("Cache-Control", "no-cache").end();
    });
}

function isValidBody(name, uri, is_paused, num_retries, uptime_sla, response_time_sla, use_ssl, response_code, interval) {
    if( typeof name === "string" 
        && typeof uri === "string" 
        && typeof is_paused === "boolean" 
        && typeof num_retries === "number" 
        && typeof uptime_sla == "number" 
        && typeof response_time_sla == "number" 
        && typeof use_ssl == "boolean" 
        && typeof response_code == "number" 
        && typeof interval == "number") 
    {
        return true;
    }
    else 
    {
        return false;
    }
}

async function checkUrlValidity(url) {
    if (url.toLowerCase().startsWith('http://') || url.toLowerCase().startsWith('https://')) {
      console.error(`Invalid URL: ${url}. URLs starting with 'http://' or 'https://' are not allowed.`);
      return false;
    }
  
    try {
      const response = await axios.head(`http://${url}`, { validateStatus: (status) => true });
  
      if (response.status >= 200 && response.status < 600) {
        console.log(`URL ${url} is valid.`);
        return true;
      } else {
        console.error(`URL ${url} responded with status ${response.status}.`);
        return false;
      }
    } catch (error) {
      console.error(`Error checking URL ${url}: ${error.message}`);
      return false;
    }
  }

async function createCustomResource(id, name, uri, is_paused, num_retries, response_code, interval, use_ssl) {
    try 
    {
    //   const namespace = await getCurrentNamespace();
      const namespace = process.env.POD_NAMESPACE;
  
      const kc = new KubeConfig();
      kc.loadFromDefault();
  
      const customObjectsApi = kc.makeApiClient(CustomObjectsApi);
  
      const group = 'webapp.kube.hellodocker.com';
      const version = 'v1';
      const plural = 'healthchecks';
  
      const body = {
        apiVersion: `${group}/${version}`,
        kind: 'HealthCheck',
        metadata: {
          name: `${id}`,
          namespace: namespace,
        },
        spec: {
          checkName: name,
          uri: uri,
          isPaused: is_paused,
          interval: interval,
          retries: num_retries,
          expectedStatusCode: response_code,
          ssl: use_ssl
        },
      };
  
      const response = await customObjectsApi.createNamespacedCustomObject(
        group,
        version,
        namespace,
        plural,
        body
      );
  
      console.log('Custom resource created:', response.body);
    } catch (error) {
      console.error('Error creating custom resource:', error);
    }
}

const postHttpCheck = async (req, res) => {
    let name = req.body.name;
    let uri = req.body.uri;
    let is_paused = req.body.is_paused;
    let num_retries = req.body.num_retries;
    let uptime_sla = req.body.uptime_sla;
    let response_time_sla = req.body.response_time_sla;
    let use_ssl = req.body.use_ssl;
    let response_code = req.body.response_status_code;
    let interval = req.body.check_interval_in_seconds;
    let count = Object.keys(req.body).length;
    if (Object.keys(req.query).length > 0) {
        res.status(400);
        res.send({"Status": 400, "Message": "Request query is not allowed."});
        return;
    }

    if(isValidBody(name, uri, is_paused, num_retries, uptime_sla, response_time_sla, use_ssl, response_code, interval) && count == 9 && await checkUrlValidity(uri))
    {
        await HttpCheck.create({
            name: name,
            uri: uri,
            is_paused: is_paused,
            num_retries: num_retries,
            uptime_sla: uptime_sla,
            response_time_sla: response_time_sla,
            use_ssl: use_ssl,
            response_status_code: response_code,
            check_interval_in_seconds: interval
        }).then(async (resp) => {
            await createCustomResource(resp.dataValues.id, name, uri, is_paused, num_retries, response_code, interval, use_ssl);
            res.status(201);
            res.send(resp.dataValues);                
        }).catch((error) => {
            // console.log(error);
            res.status(400);
            res.send({"Status": 400, "Message": "Request body is not valid."});
        });
    }
    else 
    {
        res.status(400);
        res.send({"Status": 400, "Message": "Request body is not valid."});
    }
}

const getHttpCheck = async (req, res) => {
    if (Object.keys(req.query).length > 0) {
        res.status(400);
        res.send({"Status": 400, "Message": "Request query is not allowed."});
        return;
    }
    if(Object.keys(req.body).length > 0) {
        res.status(400);
        res.send({"Status": 400, "Message": "Request body is not allowed."});
        return;
    }
    HttpCheck.findAll().then(resp => {
        res.status(200);
        res.send(resp);
    }).catch((error) => {
        console.log('Failed to get data : ', error);
    });
}

function isHttpCheckExist(check_id) {
    return new Promise(async (resolve, reject) => {
        HttpCheck.findOne({
        where: {
            id: check_id
        }}).then(res => {
            resolve(res);
        }).catch((error) => {
            reject(console.error('Failed to search for check : ', error));
        });
    });
}

const getHttpCheckId = async (req, res) => {
    const check_id = req.params.id;
    if (Object.keys(req.query).length > 0) {
        res.status(400);
        res.send({"Status": 400, "Message": "Request query is not allowed."});
        return;
    }
    if(Object.keys(req.body).length > 0) {
        res.status(400);
        res.send({"Status": 400, "Message": "Request body is not allowed."});
        return;
    }
    const exist = await isHttpCheckExist(check_id);
    if(exist) {
        HttpCheck.findOne({
        where: {
            id: check_id
        }}).then(resp => {
            res.status(200);
            res.send(resp);
        }).catch((error) => {
            console.log('Failed to get data : ', error);
        });
    }
    else 
    {
        res.status(404);
        res.send({"Status": 404, "Message": "Http Check with the given Id does not exist."});
    }
}

async function getResourceVersion(name) {
    try {
        // const namespace = await getCurrentNamespace();
        const namespace = process.env.POD_NAMESPACE;

        const kc = new KubeConfig();
        kc.loadFromDefault();

        const customObjectsApi = kc.makeApiClient(CustomObjectsApi);

        const group = 'webapp.kube.hellodocker.com';
        const version = 'v1';
        const plural = 'healthchecks';

        const resourceName = `${name}`;
        const response = await customObjectsApi.getNamespacedCustomObject(
            group,
            version,
            namespace,
            plural,
            resourceName
        );

        const resourceVersion = response.body.metadata.resourceVersion;
        console.log('Resource Version:', resourceVersion);

        return resourceVersion;
    } catch (error) {
        console.error('Error getting resource version:', error);
        return null;
    }
}

async function updateCustomResource(id, name, uri, is_paused, num_retries, response_code, interval, resourceVersion, use_ssl) {
    try {
        // const namespace = await getCurrentNamespace();
        const namespace = process.env.POD_NAMESPACE;

        const kc = new KubeConfig();
        kc.loadFromDefault();

        const customObjectsApi = kc.makeApiClient(CustomObjectsApi);

        const group = 'webapp.kube.hellodocker.com';
        const version = 'v1';
        const plural = 'healthchecks';

        const body = {
            apiVersion: `${group}/${version}`,
            kind: 'HealthCheck',
            metadata: {
                name: `${id}`,
                namespace: namespace,
                resourceVersion: resourceVersion,
            },
            spec: {
                checkName: name,
                uri: uri,
                isPaused: is_paused,
                interval: interval,
                retries: num_retries,
                expectedStatusCode: response_code,
                ssl: use_ssl
            },
        };

        const resourceName = `${id}`;
        const response = await customObjectsApi.replaceNamespacedCustomObject(
            group,
            version,
            namespace,
            plural,
            resourceName,
            body
        );

        console.log('Custom resource updated:', response.body);
    } catch (error) {
        console.error('Error updating custom resource:', error);
    }
}

const putHttpCheckId = async (req, res) => {
    let name = req.body.name;
    let uri = req.body.uri;
    let is_paused = req.body.is_paused;
    let num_retries = req.body.num_retries;
    let uptime_sla = req.body.uptime_sla;
    let response_time_sla = req.body.response_time_sla;
    let use_ssl = req.body.use_ssl;
    let response_code = req.body.response_status_code;
    let interval = req.body.check_interval_in_seconds;
    let count = Object.keys(req.body).length;
    const check_id = req.params.id;
    if (Object.keys(req.query).length > 0) {
        res.status(400);
        res.send({"Status": 400, "Message": "Request query is not allowed."});
        return;
    }
    if(isValidBody(name, uri, is_paused, num_retries, uptime_sla, response_time_sla, use_ssl, response_code, interval) && count == 9 && await checkUrlValidity(uri))
    {
        const exist = await isHttpCheckExist(check_id);
        if(exist) 
        {
            await HttpCheck.update({
                name: name,
                uri: uri,
                is_paused: is_paused,
                num_retries: num_retries,
                uptime_sla: uptime_sla,
                response_time_sla: response_time_sla,
                use_ssl: use_ssl,
                response_status_code: response_code,
                check_interval_in_seconds: interval,
            },
            { where: { id: check_id } }).then(async () => {
                const existingResourceVersion = await getResourceVersion(check_id);
                await updateCustomResource(check_id, name, uri, is_paused, num_retries, response_code, interval, existingResourceVersion, use_ssl);
                res.sendStatus(204);
            }).catch((error) => {
                res.status(400);
                res.send({"Status": 400, "Message": "Request body is not valid."});
            });
        }
        else 
        {
            res.status(404);
            res.send({"Status": 404, "Message": "Http Check with the given Id does not exist."});
        }
    }
    else 
    {
        res.status(400);
        res.send({"Status": 400, "Message": "Request body is not valid."});
    }
}

async function deleteCustomResource(id) {
    try {
        // const namespace = await getCurrentNamespace();
        const namespace = process.env.POD_NAMESPACE;

        const kc = new KubeConfig();
        kc.loadFromDefault();

        const customObjectsApi = kc.makeApiClient(CustomObjectsApi);

        const group = 'webapp.kube.hellodocker.com';
        const version = 'v1';
        const plural = 'healthchecks';

        const resourceName = `${id}`;

        const response = await customObjectsApi.deleteNamespacedCustomObject(
            group,
            version,
            namespace,
            plural,
            resourceName
        );

        console.log('Custom resource deleted:', response.body);
    } catch (error) {
        console.error('Error deleting custom resource:', error);
    }
}

const deleteHttpCheckId = async (req, res) => {
    if (Object.keys(req.query).length > 0) {
        res.status(400);
        res.send({"Status": 400, "Message": "Request query is not allowed."});
        return;
    }
    if(Object.keys(req.body).length > 0) {
        res.status(400);
        res.send({"Status": 400, "Message": "Request body is not allowed."});
        return;
    }
    const check_id = req.params.id;
    const exist = await isHttpCheckExist(check_id);
    if(exist) {
        HttpCheck.destroy({
            where: {
                id : check_id
            }
        }).then(async () => {
            await deleteCustomResource(check_id);
            res.sendStatus(204);
        }).catch((error) => {
            console.error('Failed to delete data : ', error);
        });
    }
    else 
    {
        res.status(404);
        res.send({"Status": 404, "Message": "Http Check with the given Id does not exist."});
    }
}

module.exports = {
    healthz,
    postHttpCheck,
    getHttpCheck,
    getHttpCheckId,
    putHttpCheckId,
    deleteHttpCheckId
}