using Clustering, PlotlyBase
import RDatasets: dataset
import DataFrames

using GenieFramework
@genietools

const data = DataFrames.insertcols!(dataset("datasets", "iris"), :Cluster => zeros(Int, 150))
const features = [:SepalLength, :SepalWidth, :PetalLength, :PetalWidth]

function cluster(no_of_clusters=3, no_of_iterations=10)
    feats = Matrix(data[:, [c for c in features]])' |> collect
    result = kmeans(feats, no_of_clusters; maxiter=no_of_iterations)
    data[!, :Cluster] = assignments(result)
end

@handlers begin
    @out features
    @in no_of_clusters = 3
    @in no_of_iterations = 10
    @in xfeature = :SepalLength
    @in yfeature = :SepalWidth
    @out datatable = DataTable()
    @out datatablepagination = DataTablePagination(rows_per_page=50)
    @out traces_iris = [scatter()]
    @out traces_cluster = [scatter()]
    @out layout = PlotlyBase.Layout()

    @onchange isready, xfeature, yfeature, no_of_clusters, no_of_iterations begin
        cluster(no_of_clusters, no_of_iterations)
        # plot species samples
        traces= []
        for c in unique(data.Species)
            iris_data = data[data.Species.==c, :]
            push!(traces, scatter(x=iris_data[!, xfeature], y=iris_data[!, yfeature], mode="markers", name="Species $c"))
        end
        traces_iris = traces # trigger traces_iris update
        # plot k-means result
        traces= []
        for c in unique(data.Cluster)
            cluster_data = data[data.Cluster.==c, :]
            push!(traces, scatter(x=cluster_data[!, xfeature], y=cluster_data[!, yfeature], mode="markers", name="Cluster $c"))
        end
        traces_cluster = traces # trigger traces_cluster update
        # layout with axis labels
        layout = PlotlyBase.Layout(
            xaxis=attr(title=String(xfeature)),
            yaxis=attr(title=String(yfeature),)
        )
        datatable = DataTable(data)
    end
end

@page("/", "app.jl.html")
