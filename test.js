console.log(process.env.PATH);
//=> '/usr/bin'

// Using dynamic import to import the ES module
import('fix-path').then((fixPath) => {
    fixPath.default(); // Call the default export of the fix-path module
    console.log(process.env.PATH);
    //=> '/usr/local/bin:/usr/bin'
}).catch((error) => {
    console.error('Error importing fix-path:', error);
});
