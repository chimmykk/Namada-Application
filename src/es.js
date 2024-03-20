const data = `Known payment addresses:
  "dfghjk-paymentaddress": znam1qzngqzfftzag9jzjsfkqa2sgdp99cj470fkusscr9j7p82dfggje3mf3ft6yswr4lpnymsqnxgsk2
  "eewf-paymentaddress": znam1qruemw3mmsnmv2lyuq5s442lyhq33ra7g26w7tdjn4jzdjatye8wyeeqq2alwuyqm26u7qsxw8alf
  "hfdkdfng-paymentaddress": znam1qzn7y3qjz97xc23dvcfd4el4wamq0sczaemzm8lmk8ff2utnku5gem8asx4tngj2ez0pcdskgrsrs
  "hfdkdfng-paymentadress": znam1qzn7y3qjz97xc23dvcfd4el4wamq0sczaemzm8lmk8ff2utnku5gem8asx4tngj2ez0pcdskgrsrs`
  ;

const regex = /"([^"]+-paymentaddress)"/g;

let match;
const keys = [];

// Loop through each match of the regex in the data
while ((match = regex.exec(data)) !== null) {
    // Push the first capturing group (the key) into the keys array
    keys.push(match[1]);
}

console.log(keys);
