import React, { Component } from "react";
import { TimeSeries } from "pondjs";
import {
  Charts,
  ChartContainer,
  ChartRow,
  YAxis,
  LineChart,
  ScatterChart,
  EventMarker
} from "react-timeseries-charts";
import { pluralize, minutesForHumans } from "../../utils/format";
import "./IndexBatchChart.css";

const ERROR_COLOR = '#c0392b';
const ELAPSED_COLOR = '#2980b9';

const STYLES = {
  error: {
    chart: {
      error: {
        normal: {
          stroke: ERROR_COLOR,
          strokeWidth: 1
        }
      }
    },
    axis: {
      label: {
        fill: ERROR_COLOR,
        "font-weight": "bold",
        "font-size": "12px"
      }
    }
  },
  elapsed: {
    chart: {
      elapsed: {
        normal: { stroke: ELAPSED_COLOR, strokeWidth: 1 }
      }
    },
    scatterChart: {
      elapsed: {
        normal: { stroke: ELAPSED_COLOR, strokeWidth: 1, fill: ELAPSED_COLOR }
      }
    },
    axis: {
      label: {
        fill: ELAPSED_COLOR,
        "font-weight": "bold",
        "font-size": "12px"
      }
    }
  }
};

const NullMarker = () => {
  return <g />;
};

const UNTRACKED_TITLE = "";

export default class IndexBatchChart extends Component {
  constructor(props) {
    super(props);
    const series = this.prepareTimeSeries(props.batches);
    this.state = {
      series,
      timerange: series.timerange(),
      tracker: null,
      trackerValue: "initial tracker value",
      trackerEvent: null,
      title: UNTRACKED_TITLE
    };
  }

  prepareTimeSeries(batches) {
    if (batches) {
      const seriesData = {
        name: "Indexing Runs",
        columns: ["time", "elapsed", "error"],

        points: batches
          // skip aborted batches
          .filter(batch => batch.status !== "in progress")

          // e.g. [1400425947000, 9867, 52],
          .map(batch => [
            new Date(batch.start_datetime).getTime(),
            batch.elapsed_seconds / 60,
            batch.error_count
          ])

          // reverse to put in chronological order past to present
          .reverse()
      };
      return new TimeSeries(seriesData);
    }
  }

  handleTimeRangeChange = timerange => {
    this.setState({ timerange });
  };

  handleTrackerChanged = t => {
    if (t) {
      const trackerEvent = this.state.series.atTime(t);
      const tracker = new Date(
        trackerEvent.begin().getTime() +
          (trackerEvent.end().getTime() - trackerEvent.begin().getTime()) / 2
      );
      const errorCount = trackerEvent.get("error");
      const errors = `${errorCount} ${pluralize(errorCount, "error")}`;
      const elapsedMinutes = trackerEvent.get("elapsed");
      const elapsed = `${minutesForHumans(elapsedMinutes)}`;
      const trackerValue = { errors, elapsed };
      const title = tracker.toLocaleDateString();
      this.setState({ tracker, trackerValue, trackerEvent, title });
    } else {
      this.setState({
        tracker: null,
        trackerValue: null,
        trackerEvent: null,
        title: UNTRACKED_TITLE
      });
    }
  };

  renderMarker = (axis, column, color) => {
    if (this.state.tracker) {
      return (
        <EventMarker
          type="point"
          axis={axis}
          event={this.state.trackerEvent}
          column={column}
          markerLabel={this.state.trackerValue[axis]}
          markerLabelAlign="right"
          markerLabelStyle={{
            fill: "black",
            stroke: "black",
            strokeWidth: 0.25,
            fontSize: "9px",
            fontWeight: "normal"
          }}
          markerRadius={3}
          markerStyle={{ fill: color }}
        />
      );
    } else {
      return <NullMarker />;
    }
  };

  renderChart() {
    const { series, timerange } = this.state;

    const max = {
      error: series.max("error"),
      elapsed: series.max("elapsed")
    };

    return (
      <ChartContainer
        timeRange={timerange}
        enablePanZoom={true}
        onTimeRangeChanged={this.handleTimeRangeChange}
        onTrackerChanged={this.handleTrackerChanged}
        title={this.state.title}
        titleStyle={{ fill: "black" }}
      >
        <ChartRow height="200">
          <YAxis
            id="errors"
            label="Errors (items failed)"
            max={max.error}
            style={STYLES.error.axis}
          />
          <Charts>
            <LineChart
              axis="elapsed"
              series={series}
              columns={["elapsed"]}
              style={STYLES.elapsed.chart}
            />
            <ScatterChart
              axis="elapsed"
              series={series}
              columns={["elapsed"]}
              style={STYLES.elapsed.scatterChart}
            />
            <LineChart
              axis="errors"
              series={series}
              columns={["error"]}
              style={STYLES.error.chart}
            />
            <ScatterChart
              axis="errors"
              series={series}
              columns={["error"]}
              style={STYLES.error.chart}
            />
            {this.renderMarker("errors", "error", ERROR_COLOR)}
            {this.renderMarker("elapsed", "elapsed", ELAPSED_COLOR)}
          </Charts>
          <YAxis
            id="elapsed"
            label="Duration (minutes)"
            max={max.elapsed}
            style={STYLES.elapsed.axis}
          />
        </ChartRow>
      </ChartContainer>
    );
  }

  render() {
    return <div className="index-batch-chart-container">{this.renderChart()}</div>;
  }
}
