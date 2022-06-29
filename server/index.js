const express = require('express');
const https = require('https');
const request = require('request');
const app = express();
const port = process.env.PORT || 3000;
require('dotenv').config();
const tf = require('@tensorflow/tfjs-node');
const csv = require('csv-parser');
const fs = require('fs');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;
//const tf = require("@tensorflow/tfjs")




app.get('/data', (req, res) => {
// read dummy.csv file

const path = require('path');
const csvFilePath = path.join(__dirname, 'dummy.csv');


// open dummy.csv file
const readCSV = fs.createReadStream(csvFilePath);


// read dummy.csv file and save data to array
const data1 = [];
readCSV.pipe(csv()).on('data', (data) => {
    data1.push(data);
    console.log(data);
   
}
).on('end', () => {
    console.log('CSV file successfully processed');
    res.send(data1);
}

);  


}
);










app.get('/temp', (req, res) => {

// calll http and get the data from the api

   request('https://io.adafruit.com/api/v2/tonialakik/feeds/temp/data?x-aio-key=aio_wQkR20kT1g9QcXm1rHGTFa3MHKoZ', (error, response, body) => {
        if (error) {
            console.log(error);
        } else {
            const data = JSON.parse(body);
            //get only first element of the array
            const temp = data[0].value;
            console.log(temp);
            res.send(temp)
        }
    });
});

app.get('/temp/day/:date', (req, res) => {

    // calll http and get the data from the api
    
       request('https://io.adafruit.com/api/v2/tonialakik/feeds/temp/data?limit=5000&x-aio-key=aio_wQkR20kT1g9QcXm1rHGTFa3MHKoZ', (error, response, body) => {
            if (error) {
                console.log(error);
            } else {
                const data = JSON.parse(body);
                //return values of the same :date in the array and send it to the client
                const temp = data.filter(item => item.created_at.includes(req.params.date));
                // remove "nan" values from the array
                const temp2 = temp.filter(item => item.value !== "nan");

                // average the values of temp2 and send it to the client using forEach
                let sum = 0;
                let avg = 0;
                temp2.forEach(item => {
                    sum += parseFloat(item.value);
                    console.log(sum);
                }
                );
                avg = sum / temp2.length;
                res.send(avg.toFixed(2));
            }
        });
    });



//get request for weather with city name
app.get('/weather/:city', (req, res) => {
    const city = req.params.city;
    
    const url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&&units=metric&appid=${process.env.API_KEY}`;
    request(url, (error, response, body) => {
        if (error) {
            console.log(error);
        } else {
            //return only temp
            const data = JSON.parse(body);
            const temp = data.main.temp;

            res.send(""+temp);
        }
    });});



    //get request for weather with city name
app.get('/live_weather/:city', (req, res) => {
    const city = req.params.city;
    
    const url = `https://api.weatherapi.com/v1/current.json?key=${process.env.WEA_KEY}&q=${city}&aqi=no`;
    request(url, (error, response, body) => {
        if (error) {
            console.log(error);
        } else {
            //return only temp
            const data = JSON.parse(body);
            const temp = data.current.temp_c;

            res.send(""+temp);
        }
    });});

//     var cron = require('node-cron');
// cron.schedule('*/1 * * * *', () => {
//   console.log('running a task in 1 minutes');
// })


    //get request for weather with city name for next 5 days
    app.get('/weather/:city/5days', (req, res) => {
        const city = req.params.city;
        const url = `https://api.openweathermap.org/data/2.5/forecast/?q=${city}&units=metric&appid=${process.env.API_KEY}`;
        request(url, (error, response, body) => {
            if (error) {
                console.log(error);
            } else {
            //return dt_txt only days
            const data = JSON.parse(body);
            const days = data.list.map(item => item.dt_txt);
            //remove time from days array
            const daysWithoutTime = days.map(item => item.slice(0,10));
            //remove duplicates from days array
            const uniqueDays = [...new Set(daysWithoutTime)];
            // calculate average temp for each day using uniqueDays array and data.list array
            const averageTemp = uniqueDays.map(day => {
                const temp = data.list.filter(item => item.dt_txt.slice(0,10) === day);
                const tempSum = temp.reduce((acc, item) => acc + item.main.temp, 0);
                return parseFloat((tempSum / temp.length)).toFixed(2);
            }
            );
            res.send(averageTemp);
            }        
        });});

// using tensorflow to predict sensor_temp from dummy.csv file and send it to the client
app.get('/calibrate', async (req, res) => {
   await trainmodel();
res.send("done");
}
);


async function trainmodel() {
    const path = require('path');
    const csvFilePath = path.join(__dirname, 'dummy.csv');
    const csv = require('csvtojson');
    csv().fromFile(csvFilePath).then((jsonObj) => {
        const data = jsonObj;
        // const x = data.map(item => parseFloat(item.weather_temp));
        // const y = data.map(item => parseFloat(item.sensor_temp));
        const x = data.map(item => [ parseFloat(item.date),parseFloat(item.weather_temp)]);
        const y = data.map(item => parseFloat(item.sensor_temp));

        console.log(x);
        console.log(y);


        const model = tf.sequential();
        model.add(tf.layers.dense({inputShape: [2], units: 1, useBias: true}));
        model.add(tf.layers.dense({units: 1, useBias: true}));
        //set model learning rate to 0.0001
        const optimizer = tf.train.sgd(0.0001);
        model.compile({loss: 'meanSquaredError', optimizer: optimizer});
        const xs = tf.tensor2d(x);
        const ys = tf.tensor1d(y);
        model.weights.forEach(w => {
            console.log(w.name, w.shape);
           });
        model.fit(xs, ys, {epochs: 300}).then(() => {
            // const prediction = model.predict(tf.tensor2d([[14,29]]));
            // const output = prediction.dataSync();
            // console.log(output);
            model.save('file://./sensor_ai');
                 
        }
        
        );
    }
    );

}


// Load tensorflow model and predict the value from the client input date and weather temp
app.get('/predict/:date/:weather_temp', async (req, res) => {
    const date = req.params.date;
    const weather_temp = req.params.weather_temp;
    const model = await tf.loadLayersModel('file://./sensor_ai/model.json');
    const prediction = await model.predict(tf.tensor2d([[parseFloat(date),parseFloat(weather_temp)]]));
    const output = await prediction.dataSync();
    console.log(output);
    res.send(output[0].toFixed(1));
}
);

app.get('/start_collecting', async (req, res) => {
//run a cron job to start collecting data every hour at minute 0 and send the data to the server for the next 7 days
    collectdata();
    res.send("Calibrating the model , takes 7 days to complete");

}
);


async function collectdata()  {
console.log("started collecting");
    const cron = require('node-cron');
    var hourlytemp;
    var hourlysensor;
    var timehour;

    cron.schedule('0 * * * *',  () => {
      
        const url = `https://api.openweathermap.org/data/2.5/weather?q=Beirut&appid=a2ea8f2c4845faf13d7dd5c8223cd62d&units=metric`;
        request(url, (error, response, body) => {
            if (error) {
                console.log(error);
            } else {
                //return only temp
                const data = JSON.parse(body);
                const temp = data.main.temp;
                const time = data.dt;
                const timehour1 = new Date(time*1000).getHours();
                hourlytemp = temp;
                timehour = timehour1;
                console.log(timehour);
                console.log(hourlytemp);
            }
        });

        request('https://io.adafruit.com/api/v2/tonialakik/feeds/temp/data?x-aio-key=aio_wQkR20kT1g9QcXm1rHGTFa3MHKoZ', (error, response, body) => {
            if (error) {
                console.log(error);
            } else {
                const data = JSON.parse(body);
                //get only first element of the array
                const temp = data[0].value;
                console.log(temp);
                hourlysensor = temp;

            }

        });
        // get sevrer time and add it to the data
        setTimeout(function(){
            csvdata = "\r\n"+timehour+","+hourlytemp+","+hourlysensor;
            fs.appendFileSync("dummy.csv", csvdata);
            console.log("Done!");
       }, 10000);
    


    });



    
}



    const cron = require('node-cron');
    cron.schedule('0 0 * * 0', () => {
        trainmodel();
    
    
    }
    );
    







app.listen(port, () => console.log(`Hello world app listening on port ${port}!`));