package com.example.ble_flutter.ui

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.*
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.*
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.ble_flutter.BuildConfig
import com.example.ble_flutter.ble.ConnectionManager
import com.example.ble_flutter.ble.printProperties
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import org.jetbrains.anko.alert
import org.json.JSONArray
import org.json.JSONObject
import timber.log.Timber
import java.util.concurrent.TimeUnit


private const val ENABLE_BLUETOOTH_REQUEST_CODE = 1
private const val LOCATION_PERMISSION_REQUEST_CODE = 2


class MainActivity : FlutterActivity() {
    private var timerSubscriptionForBle: Disposable? = null
    private var timerSubscriptionForBleChart: Disposable? = null
    private var bleDeviceSelectedIndex: Int = 0

    /*******************************************
     * Properties
     *******************************************/

    private val bluetoothAdapter: BluetoothAdapter by lazy {
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothManager.adapter
    }

    private val bleScanner by lazy {
        bluetoothAdapter.bluetoothLeScanner
    }

    private val scanSettings = ScanSettings.Builder()
        .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
        .build()

    private var isScanning = false
//        set(value) {
//            field = value
//            runOnUiThread { scan_button.text = if (value) "Stop Scan" else "Start Scan" }
//        }

    private val scanResults = mutableListOf<ScanResult>()
//    private val scanResultAdapter: ScanResultAdapter by lazy {
//        ScanResultAdapter(scanResults) { result ->
//            if (isScanning) {
//                stopBleScan()
//            }
//            with(result.device) {
//                Timber.w("Connecting to $address")
//                ConnectionManager.connect(this, this@MainActivity)
//            }
//        }
//    }

    private val isLocationPermissionGranted
        get() = hasPermission(Manifest.permission.ACCESS_FINE_LOCATION)

    /*******************************************
     * Activity function overrides
     *******************************************/

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //setContentView(R.layout.activity_main)
        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
        }
//        scan_button.setOnClickListener {
//            if (isScanning) stopBleScan() else startBleScan() }
        //setupRecyclerView()
    }

    override fun onResume() {
        super.onResume()
        // ConnectionManager.registerListener(connectionEventListener)
        if (!bluetoothAdapter.isEnabled) {
            promptEnableBluetooth()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            ENABLE_BLUETOOTH_REQUEST_CODE -> {
                if (resultCode != Activity.RESULT_OK) {
                    promptEnableBluetooth()
                }
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            LOCATION_PERMISSION_REQUEST_CODE -> {
                if (grantResults.firstOrNull() == PackageManager.PERMISSION_DENIED) {
                    requestLocationPermission()
                } else {
                    startBleScan()
                }
            }
        }
    }

    /*******************************************
     * Private functions
     *******************************************/

    private fun promptEnableBluetooth() {
        if (!bluetoothAdapter.isEnabled) {
            val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            startActivityForResult(enableBtIntent, ENABLE_BLUETOOTH_REQUEST_CODE)
        }
    }

    private fun startBleScan() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !isLocationPermissionGranted) {
            requestLocationPermission()
        } else {
            scanResults.clear()
            //scanResultAdapter.notifyDataSetChanged()
            bleScanner.startScan(null, scanSettings, scanCallback)
            isScanning = true
        }
    }

    private fun stopBleScan() {
        bleScanner.stopScan(scanCallback)
        isScanning = false
    }

    private fun requestLocationPermission() {
        if (isLocationPermissionGranted) {
            return
        }
        runOnUiThread {
            alert {
                title = "Location permission required"
                message = "Starting from Android M (6.0), the system requires apps to be granted " +
                        "location access in order to scan for BLE devices."
                isCancelable = false
                positiveButton(android.R.string.ok) {
                    requestPermission(
                        Manifest.permission.ACCESS_FINE_LOCATION,
                        LOCATION_PERMISSION_REQUEST_CODE
                    )
                }
            }.show()
        }
    }

//    private fun setupRecyclerView() {
//        scan_results_recycler_view.apply {
//            adapter = scanResultAdapter
//            layoutManager = LinearLayoutManager(
//                this@MainActivity,
//                RecyclerView.VERTICAL,
//                false
//            )
//            isNestedScrollingEnabled = false
//        }
//
//        val animator = scan_results_recycler_view.itemAnimator
//        if (animator is SimpleItemAnimator) {
//            animator.supportsChangeAnimations = false
//        }
//    }

    /*******************************************
     * Callback bodies
     *******************************************/
    lateinit var bleDetailJson: JSONObject
    lateinit var result1: ScanResult
    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            val indexQuery = scanResults.indexOfFirst { it.device.address == result.device.address }
            if (indexQuery != -1) { // A scan result already exists with the same address
                scanResults[indexQuery] = result
                //scanResultAdapter.notifyItemChanged(indexQuery)
            } else {
                with(result.device) {
                    Timber.i("Found BLE device! Name: ${name ?: "Unnamed"}, address: $address")
                }
                scanResults.add(result)
                result1 = result
                bleDetailJson = JSONObject();
                val detailsArray = JSONArray()
                for (item in scanResults.indices) {
                    val internalJson = JSONObject()
                    internalJson.put("device_name", scanResults[item].device.name ?: "Unnamed")
                    internalJson.put("device_address", scanResults[item].device.address.toString())
                    internalJson.put("device_rssi", "${scanResults[item].rssi} dBm")
                    detailsArray.put(internalJson)

                }
                bleDetailJson.put("BLEDeviceDetail", detailsArray)
                //Log.e("Lis",bleDetailJson.toString())
                //scanResultAdapter.notifyItemInserted(scanResults.size - 1)
            }
        }

        override fun onScanFailed(errorCode: Int) {
            Timber.e("onScanFailed: code $errorCode")
        }
    }

//    private val connectionEventListener by lazy {
//        ConnectionEventListener().apply {
//            onConnectionSetupComplete = { gatt ->
////                Intent(this@MainActivity, BleOperationsActivity::class.java).also {
////                    it.putExtra(BluetoothDevice.EXTRA_DEVICE, gatt.device)
////                    startActivity(it)
////                }
//                ConnectionManager.unregisterListener(this)
//            }
//            onDisconnect = {
//                runOnUiThread {
//                    alert {
//                        title = "Disconnected"
//                        message = "Disconnected or unable to connect to device."
//                        positiveButton("OK") {}
//                    }.show()
//                }
//            }
//        }
//    }

    /*******************************************
     * Extension functions
     *******************************************/

    private fun Context.hasPermission(permissionType: String): Boolean {
        return ContextCompat.checkSelfPermission(this, permissionType) ==
                PackageManager.PERMISSION_GRANTED
    }

    private fun Activity.requestPermission(permission: String, requestCode: Int) {
        ActivityCompat.requestPermissions(this, arrayOf(permission), requestCode)
    }


    //****************************************** Flutter Code  ******************
    private val BLE_SCAN_CHANNEL = "samples.flutter.io/scan_ble_devices"
    private val GET_BLE_SCAN_INFO_CHANNEL = "samples.flutter.io/get_scan_ble_info";
    private val GET_BLE_CHARACT_INFO_CHANNEL = "samples.flutter.io/get_ble_characteristic_info";

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BLE_SCAN_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "scanBLEDevices") {
                if (!bluetoothAdapter.isEnabled) {
                    promptEnableBluetooth()
                } else {

                    if (isScanning) stopBleScan() else startBleScan()
                    Log.e("Scan---", "" + isScanning)

                    if (isScanning) {
                        result.success("Stop Scan")
                    } else if (!isScanning) {
                        result.success("Start Scan")
                        if (bleDetailJson.length() > 0) {
                            bleDetailJson = JSONObject();
                        }
                    } else {
                        result.error("UNAVAILABLE", "BLE device not available.", null)
                    }
                }
            } else if (call.method == "connectBLEDevices") {

                bleDeviceSelectedIndex = call.argument<Int>("text")!!

                Log.e("GATT", scanResults[bleDeviceSelectedIndex!!].device.toString());

                getBLECharacteristicInfo(bleDeviceSelectedIndex)

                result.success("")

            } else {
                result.notImplemented()
            }
        };
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            GET_BLE_SCAN_INFO_CHANNEL
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                @SuppressLint("LogNotTimber")
                @Override
                override fun onListen(args: Any?, events: EventChannel.EventSink) {
                    Log.w("TAG", "adding listener")
                    timerSubscriptionForBle = Observable
                        .interval(0, 10, TimeUnit.SECONDS)
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(
                            { timer: Long ->
                                Log.w(
                                    "TAG",
                                    "emitting timer event $timer"
                                )
                                if (::bleDetailJson.isInitialized) {
                                    events.success(bleDetailJson.toString())
                                }
                            },
                            { error: Throwable ->
                                Log.e("TAG", "error in emitting timer", error)
                                events.error(
                                    "STREAM",
                                    "Error in processing observable",
                                    error.message
                                )
                            }
                        ) {
                            Log.w("TAG", "closing the timer observable")
                        }
                }

                @SuppressLint("LogNotTimber")
                @Override
                override fun onCancel(args: Any?) {
                    Log.w("TAG", "cancelling listener")
                    if (timerSubscriptionForBle != null) {
                        timerSubscriptionForBle!!.dispose()
                        timerSubscriptionForBle = null
                    }
                }
            }
        );
        //Channel For Get Ble Charateristics
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            GET_BLE_CHARACT_INFO_CHANNEL
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                @SuppressLint("LogNotTimber")
                @Override
                override fun onListen(args: Any?, events: EventChannel.EventSink) {
                    Log.w("TAG", "adding listener")
                    timerSubscriptionForBleChart = Observable
                        .interval(0, 5, TimeUnit.SECONDS)
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(
                            { timer: Long ->
                                Log.w(
                                    "TAG",
                                    "emitting timer event $timer"
                                )
                                events.success(getBLECharacteristicInfo(bleDeviceSelectedIndex).toString())
                            },
                            { error: Throwable ->
                                Log.e("TAG", "error in emitting timer", error)
                                events.error(
                                    "STREAM",
                                    "Error in processing observable",
                                    error.message
                                )
                            }
                        ) {
                            Log.w("TAG", "closing the timer observable")
                        }
                }

                @SuppressLint("LogNotTimber")
                @Override
                override fun onCancel(args: Any?) {
                    Log.w("TAG", "cancelling listener")
                    if (timerSubscriptionForBleChart != null) {
                        timerSubscriptionForBleChart!!.dispose()
                        timerSubscriptionForBleChart = null
                    }
                }
            }
        )

    }

    override fun onDestroy() {
        super.onDestroy()

        if (timerSubscriptionForBle != null) {
            timerSubscriptionForBle!!.dispose()
            timerSubscriptionForBle = null
        }
        if (timerSubscriptionForBleChart != null) {
            timerSubscriptionForBleChart!!.dispose()
            timerSubscriptionForBleChart = null
        }
    }

    private fun getBLECharacteristicInfo(index: Int): JSONObject {
        with(scanResults) {
            Timber.w("Connecting to $scanResults[index!!].device")
            ConnectionManager.connect(scanResults[index].device, this@MainActivity)
        }

        val characteristics = ConnectionManager.servicesOnDevice(scanResults[index].device)
            ?.flatMap { service ->

                service.characteristics ?: listOf()
            } ?: listOf()


        val charDetailJson = JSONObject();
        val detailsArray = JSONArray()
        for (item in characteristics.indices) {
            val internalJson = JSONObject()
            internalJson.put("UUID", characteristics[item].uuid)
            internalJson.put("print_prop", characteristics[item].printProperties())

            detailsArray.put(internalJson)

        }
        charDetailJson.put("BLECharDetail", detailsArray)
        Log.e("GSON", charDetailJson.toString())
        return charDetailJson

    }

    fun isBluetoothEnabled(): Boolean {
        val myBluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        return myBluetoothAdapter.isEnabled
    }
}


